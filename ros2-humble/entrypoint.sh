#!/usr/bin/env bash
set -e

source "/opt/ros/${ROS_DISTRO:-humble}/setup.bash"

# /run 和部分 /tmp 内容可能在容器重启时被清空。
install -d -m 0755 /run/sshd
install -d -m 1777 /tmp/.X11-unix
install -d -m 0700 /tmp/runtime-root
rm -f /tmp/.X99-lock /tmp/.X11-unix/X99
ssh-keygen -A

exec "$@"
