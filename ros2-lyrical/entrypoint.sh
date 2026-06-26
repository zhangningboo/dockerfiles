#!/bin/bash
set -e

source /opt/ros/lyrical/setup.bash

service ssh start

# =========================
# Foxglove Bridge
# =========================
echo "[INFO] Starting Foxglove Bridge..."

ros2 launch foxglove_bridge foxglove_bridge_launch.xml \
    port:=8765 \
    address:=0.0.0.0