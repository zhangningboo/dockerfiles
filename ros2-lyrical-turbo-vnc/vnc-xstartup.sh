#!/usr/bin/env bash
set -e

unset SESSION_MANAGER

export XDG_CURRENT_DESKTOP=Fluxbox
export XDG_SESSION_DESKTOP=fluxbox
export XDG_SESSION_TYPE=x11
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"

runtime_dir="${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}"
mkdir -p "${runtime_dir}"
chmod 700 "${runtime_dir}"
export XDG_RUNTIME_DIR="${runtime_dir}"

if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    exec dbus-run-session -- "$0"
fi

xsetroot -solid '#2e3440'
xterm -geometry 120x36+20+20 -title 'ROS 2 Lyrical' -e /bin/zsh -l &

exec fluxbox
