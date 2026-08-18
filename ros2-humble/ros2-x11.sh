#!/usr/bin/env bash
set -e

if [[ -z "${AMENT_PREFIX_PATH:-}" ]]; then
    source "/opt/ros/${ROS_DISTRO:-humble}/setup.bash"
fi

# launch/run 可能创建 RViz、rqt 等 OpenGL 子进程，让整个进程树继承
# VirtualGL；其他 ROS CLI 子命令保持原始执行路径。
case "${1:-}" in
    launch|run)
        if [[ -z "${DISPLAY:-}" ]]; then
            echo "ros2 ${1}: DISPLAY is not set; connect from macOS with: DISPLAY=:0 ssh -Y ..." >&2
            exit 1
        fi

        export QT_X11_NO_MITSHM=1
        export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-root}"
        install -d -m 0700 "${XDG_RUNTIME_DIR}"

        exec /opt/VirtualGL/bin/vglrun \
            -c proxy \
            -d "${VGL_DISPLAY:-:99}" \
            /opt/ros/humble/bin/ros2 "$@"
        ;;
    *)
        exec /opt/ros/humble/bin/ros2 "$@"
        ;;
esac
