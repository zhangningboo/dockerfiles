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
VNC_SECURITY_TYPES="${VNC_SECURITY_TYPES:-TLSVnc}"
VNC_LOCALHOST="${VNC_LOCALHOST:-0}"
VNC_HOME="${HOME}/.vnc"

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

stop_vnc() {
    trap - TERM INT
    echo "[INFO] Stopping TurboVNC ${VNC_DISPLAY}."
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
trap 'stop_vnc; exit 0' TERM INT

if (($# > 0)); then
    "$@" &
    command_pid=$!
    if wait "${command_pid}"; then
        command_status=0
    else
        command_status=$?
    fi
    stop_vnc
    exit "${command_status}"
fi

wait "${vnc_pid}"
