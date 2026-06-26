### foxglove
```shell
$ podman build -t registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_arm64_v8_ros:ros2-humble-ros-base-foxglove-gui .

$ podman run -d \
  -p 8000:8000 \
  -p 8765:8765 \
  -p 2222:22 \
  --name ros2-humble-ros-base-foxglove-gui \
  registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_arm64_v8_ros:ros2-humble-ros-base-foxglove-gui

$ podman exec -it ros2-humble-ros-base-foxglove-gui zsh
```

