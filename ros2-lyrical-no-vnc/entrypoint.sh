#!/usr/bin/env bash
set -Eeo pipefail

# ROS 环境脚本会读取未定义的可选变量，因此在它加载完成后再启用 nounset。
source /opt/ros/lyrical/setup.bash
set -u

mkdir -p /run/sshd
service ssh start

VNC_DISPLAY="${VNC_DISPLAY:-:1}"
VNC_GEOMETRY="${VNC_GEOMETRY:-1920x1080}"
VNC_DEPTH="${VNC_DEPTH:-24}"
VNC_SECURITY_TYPES="${VNC_SECURITY_TYPES:-VNC}"
VNC_LOCALHOST="${VNC_LOCALHOST:-1}"
VNC_HOME="${HOME}/.vnc"
NOVNC_PORT="${NOVNC_PORT:-6080}"
NOVNC_WEB_ROOT="${NOVNC_WEB_ROOT:-/usr/share/novnc}"

if [[ ! "${VNC_DISPLAY}" =~ ^:([0-9]+)$ ]]; then
    echo "[ERROR] VNC_DISPLAY must look like :1, got: ${VNC_DISPLAY}" >&2
    exit 2
fi

display_number="${BASH_REMATCH[1]}"
VNC_PORT="${VNC_PORT:-$((5900 + display_number))}"

if [[ ! "${VNC_GEOMETRY}" =~ ^[0-9]+x[0-9]+$ ]]; then
    echo "[ERROR] VNC_GEOMETRY must look like 1920x1080, got: ${VNC_GEOMETRY}" >&2
    exit 2
fi
if [[ ! "${VNC_DEPTH}" =~ ^(8|16|24|30|32)$ ]]; then
    echo "[ERROR] VNC_DEPTH must be one of 8, 16, 24, 30, or 32." >&2
    exit 2
fi
if [[ ! "${VNC_PORT}" =~ ^[0-9]+$ ]] || ((VNC_PORT < 1 || VNC_PORT > 65535)); then
    echo "[ERROR] VNC_PORT must be between 1 and 65535, got: ${VNC_PORT}" >&2
    exit 2
fi
if [[ ! "${NOVNC_PORT}" =~ ^[0-9]+$ ]] || ((NOVNC_PORT < 1 || NOVNC_PORT > 65535)); then
    echo "[ERROR] NOVNC_PORT must be between 1 and 65535, got: ${NOVNC_PORT}" >&2
    exit 2
fi
if [[ ! -f "${NOVNC_WEB_ROOT}/vnc.html" ]]; then
    echo "[ERROR] noVNC web root is invalid: ${NOVNC_WEB_ROOT}" >&2
    exit 2
fi

mkdir -p "${VNC_HOME}"
chmod 700 "${VNC_HOME}"

if [[ -n "${VNC_PASSWORD_FILE:-}" ]]; then
    if [[ ! -r "${VNC_PASSWORD_FILE}" ]]; then
        echo "[ERROR] VNC_PASSWORD_FILE is not readable: ${VNC_PASSWORD_FILE}" >&2
        exit 2
    fi
    VNC_PASSWORD="$(<"${VNC_PASSWORD_FILE}")"
fi

if [[ -n "${VNC_PASSWORD:-}" ]]; then
    if ((${#VNC_PASSWORD} < 6)); then
        echo "[ERROR] VNC_PASSWORD must contain at least 6 characters." >&2
        exit 2
    fi
    if ((${#VNC_PASSWORD} > 8)); then
        echo "[WARN] TurboVNC VNC authentication uses only the first 8 password characters."
    fi
    umask 077
    printf '%s\n' "${VNC_PASSWORD}" | /opt/TurboVNC/bin/vncpasswd -f > "${VNC_HOME}/passwd"
    unset VNC_PASSWORD
elif [[ ! -s "${VNC_HOME}/passwd" ]]; then
    echo "[ERROR] Set VNC_PASSWORD (6+ characters) or VNC_PASSWORD_FILE before starting the container." >&2
    exit 2
fi
chmod 600 "${VNC_HOME}/passwd"

vnc_args=(
    "${VNC_DISPLAY}"
    -fg
    -geometry "${VNC_GEOMETRY}"
    -depth "${VNC_DEPTH}"
    -rfbport "${VNC_PORT}"
    -rfbauth "${VNC_HOME}/passwd"
    -securitytypes "${VNC_SECURITY_TYPES}"
    -xstartup /usr/local/bin/vnc-xstartup
)

case "${VNC_LOCALHOST,,}" in
    1|true|yes) vnc_args+=(-localhost) ;;
    0|false|no) ;;
    *) echo "[ERROR] VNC_LOCALHOST must be true/false or 1/0." >&2; exit 2 ;;
esac

echo "[INFO] Starting TurboVNC ${VNC_DISPLAY} on TCP port ${VNC_PORT} (${VNC_GEOMETRY}x${VNC_DEPTH})."

/opt/TurboVNC/bin/vncserver "${vnc_args[@]}" &
vnc_pid=$!
novnc_pid=""
vnc_ready=0

for _ in {1..100}; do
    if netstat -lnt 2>/dev/null | awk -v address="127.0.0.1:${VNC_PORT}" \
        '$4 == address { found=1 } END { exit(found ? 0 : 1) }'; then
        vnc_ready=1
        break
    fi
    if ! kill -0 "${vnc_pid}" 2>/dev/null; then
        wait "${vnc_pid}"
        exit $?
    fi
    sleep 0.1
done

if ((vnc_ready == 0)); then
    echo "[ERROR] TurboVNC did not open TCP port ${VNC_PORT}." >&2
    kill "${vnc_pid}" 2>/dev/null || true
    wait "${vnc_pid}" 2>/dev/null || true
    exit 1
fi

novnc_args=(--web "${NOVNC_WEB_ROOT}")
if [[ -n "${NOVNC_CERT:-}" || -n "${NOVNC_KEY:-}" ]]; then
    if [[ -z "${NOVNC_CERT:-}" || -z "${NOVNC_KEY:-}" ]]; then
        echo "[ERROR] NOVNC_CERT and NOVNC_KEY must be supplied together." >&2
        exit 2
    fi
    if [[ ! -r "${NOVNC_CERT}" || ! -r "${NOVNC_KEY}" ]]; then
        echo "[ERROR] noVNC TLS certificate or key is not readable." >&2
        exit 2
    fi
    novnc_args+=(--cert "${NOVNC_CERT}" --key "${NOVNC_KEY}" --ssl-only)
fi

websockify "${novnc_args[@]}" "${NOVNC_PORT}" "127.0.0.1:${VNC_PORT}" &
novnc_pid=$!

novnc_ready=0
for _ in {1..50}; do
    if netstat -lnt 2>/dev/null | awk -v port=":${NOVNC_PORT}" \
        '$4 ~ (port "$") { found=1 } END { exit(found ? 0 : 1) }'; then
        novnc_ready=1
        break
    fi
    if ! kill -0 "${novnc_pid}" 2>/dev/null; then
        wait "${novnc_pid}"
        exit $?
    fi
    sleep 0.1
done

if ((novnc_ready == 0)); then
    echo "[ERROR] noVNC did not open TCP port ${NOVNC_PORT}." >&2
    kill "${novnc_pid}" "${vnc_pid}" 2>/dev/null || true
    wait "${novnc_pid}" "${vnc_pid}" 2>/dev/null || true
    exit 1
fi

scheme=http
[[ -n "${NOVNC_CERT:-}" ]] && scheme=https
echo "[INFO] noVNC is ready at ${scheme}://0.0.0.0:${NOVNC_PORT}/vnc.html?autoconnect=1&resize=remote"

stop_services() {
    trap - TERM INT
    echo "[INFO] Stopping noVNC and TurboVNC ${VNC_DISPLAY}."
    if [[ -n "${novnc_pid}" ]]; then
        kill "${novnc_pid}" 2>/dev/null || true
        wait "${novnc_pid}" 2>/dev/null || true
    fi
    vnc_pid_file="${VNC_HOME}/$(hostname)${VNC_DISPLAY}.pid"
    if [[ -s "${vnc_pid_file}" ]]; then
        xvnc_pid="$(<"${vnc_pid_file}")"
        if [[ "${xvnc_pid}" =~ ^[0-9]+$ ]]; then
            kill "${xvnc_pid}" 2>/dev/null || true
        fi
    fi
    kill "${vnc_pid}" 2>/dev/null || true
    wait "${vnc_pid}" 2>/dev/null || true
}
trap 'stop_services; exit 0' TERM INT

if (($# > 0)); then
    "$@" &
    command_pid=$!
    if wait "${command_pid}"; then
        command_status=0
    else
        command_status=$?
    fi
    stop_services
    exit "${command_status}"
fi

if wait -n "${vnc_pid}" "${novnc_pid}"; then
    service_status=0
else
    service_status=$?
fi
stop_services
exit "${service_status}"
