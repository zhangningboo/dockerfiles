### 构建

```shell
podman build --layers \
  -t registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_arm64_v8_ros:ros2-humble-ros-base-foxglove-gui \
  .
```

默认使用 ARM64 Ubuntu 22.04 基础镜像。如需构建 CUDA/AMD64 版本，可以覆盖 `BASE_IMAGE`：

```shell
podman build --layers \
  --build-arg BASE_IMAGE=registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_amd64_cuda:13.0.2-cudnn-devel-ubuntu22.04 \
  -t ros2-humble:cuda \
  .
```

### 运行

```shell
podman run -d \
  -p 8765:8765 \
  -p 2222:22 \
  --name ros2-humble-ros-base-foxglove-gui \
  registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_arm64_v8_ros:ros2-humble-ros-base-foxglove-gui

podman exec -it ros2-humble-ros-base-foxglove-gui zsh
```

`podman exec` 适合普通命令行调试，但它不会建立 X11 转发；启动 RViz 请使用
下面的 `ssh -Y` 方式。

容器启动后，Supervisor 运行 SSH、Foxglove Bridge 和一个仅供 OpenGL
渲染使用的后台 Xvfb。不会自动启动 RViz、VNC 或 Linux 桌面。Foxglove 使用
`ws://<主机地址>:8765` 访问；RViz 按需通过 macOS XQuartz 显示为单独窗口。

### macOS 启动 RViz

确认已经安装并启动 XQuartz：

```shell
open -a XQuartz
```

通过可信 X11 转发登录容器，默认密码为 `ubuntu`：

```shell
DISPLAY=:0 ssh -Y -p 2222 root@127.0.0.1
```

进入容器后确认 `DISPLAY` 已由 SSH 自动设置，再启动 RViz：

```shell
echo "$DISPLAY"
rviz2
```

`rviz2` 在交互式 Bash/Zsh 中已映射到 `rviz2-x11`：VirtualGL 在后台 Xvfb
中以 OpenGL 4.5 渲染，再通过 SSH/XQuartz 只传输 RViz 窗口。`DISPLAY`
应类似 `localhost:10.0`。该方式不需要 VNC，也不需要执行 `xhost +` 或开放
X11 的 TCP 6000 端口。

查看常驻进程状态：

```shell
podman exec ros2-humble-ros-base-foxglove-gui \
  supervisorctl -c /etc/supervisor/conf.d/ros2.conf status
```
