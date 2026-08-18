#!/usr/bin/env bash
set -e

if [[ -z "${DISPLAY:-}" ]]; then
    echo "rviz2: DISPLAY is not set; connect from macOS with: DISPLAY=:0 ssh -Y ..." >&2
    exit 1
fi

export QT_X11_NO_MITSHM=1
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-root}"
install -d -m 0700 "${XDG_RUNTIME_DIR}"

if [[ -z "${AMENT_PREFIX_PATH:-}" ]]; then
    source "/opt/ros/${ROS_DISTRO:-humble}/setup.bash"
fi

exec /opt/VirtualGL/bin/vglrun \
    -c proxy \
    -d "${VGL_DISPLAY:-:99}" \
    /opt/ros/humble/bin/rviz2 "$@"
