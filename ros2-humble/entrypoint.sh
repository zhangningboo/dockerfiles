#!/bin/bash
set -e

source /opt/ros/humble/setup.bash

# =========================
# 1. Virtual Display (VNC)
# =========================
export DISPLAY=:99

Xvfb :99 -screen 0 1920x1080x24 &
fluxbox &

x11vnc -display :99 \
       -nopw \
       -forever \
       -shared \
       -rfbport 5901 &

/opt/novnc/utils/novnc_proxy \
    --vnc localhost:5901 \
    --listen 6080 &

# =========================
# 2. Foxglove Bridge
# =========================
echo "[INFO] Starting Foxglove Bridge..."

ros2 launch foxglove_bridge foxglove_bridge_launch.xml \
    port:=8765 \
    address:=0.0.0.0