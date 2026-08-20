# ROS 2 Jazzy + TurboVNC

该镜像基于 Ubuntu 24.04 Noble，在容器内启动 ROS 2 Jazzy、Fluxbox 桌面和 TurboVNC。无需挂载宿主机 `DISPLAY` / `.Xauthority`，也无需启用 `--privileged`。默认 VNC 显示号为 `:1`、端口为 `5901`，连接安全类型为 `TLSVnc`。

## 构建

ARM64（默认）：

```shell
docker build -t ros2-jazzy-turbovnc ./ros2-jazzy-turbo-vnc
```

AMD64：

```shell
docker build \
  --platform=linux/amd64 \
  --build-arg BASE_IMAGE=registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_amd64_ubuntu:24.04 \
  -t ros2-jazzy-turbovnc:amd64 \
  ./ros2-jazzy-turbo-vnc
```

## 启动和连接

```shell
docker run -d \
  --name ros2-jazzy-vnc \
  --shm-size=2g \
  -p 5901:5901 \
  -e VNC_PASSWORD='change-me' \
  ros2-jazzy-turbovnc
```

在 TurboVNC Viewer 中连接：

```text
<Docker 宿主机 IP>:5901
```

进入容器后可直接启动 RViz：

```shell
docker exec -it ros2-jazzy-vnc zsh
rviz2
```

VNC 口令至少 6 个字符；VNC 协议实际只使用前 8 个字符。也可以用 Docker secret 或挂载文件避免把口令直接写入命令行：

```shell
docker run -d \
  --name ros2-jazzy-vnc \
  --shm-size=2g \
  -p 5901:5901 \
  -v /path/to/vnc-password:/run/secrets/vnc-password:ro \
  -e VNC_PASSWORD_FILE=/run/secrets/vnc-password \
  ros2-jazzy-turbovnc
```

## 可配置项

| 环境变量 | 默认值 | 说明 |
| --- | --- | --- |
| `VNC_DISPLAY` | `:1` | VNC 显示号 |
| `VNC_PORT` | `5900 + 显示号` | VNC TCP 端口 |
| `VNC_GEOMETRY` | `1920x1080` | 桌面分辨率 |
| `VNC_DEPTH` | `24` | 色深 |
| `VNC_SECURITY_TYPES` | `TLSVnc` | TurboVNC 安全类型 |
| `VNC_LOCALHOST` | `0` | 设为 `1` 时仅监听容器回环地址 |
| `LIBGL_ALWAYS_SOFTWARE` | `1` | 默认使用 Mesa 软件 OpenGL |

镜像默认设置 `DISPLAY=:1`，因此 `docker exec` 进入容器后可直接运行 RViz2。如果修改 `VNC_DISPLAY`，请同时将 `DISPLAY` 设为相同值。

如果客户端不支持 `TLSVnc`，可在受信任网络中临时使用 `-e VNC_SECURITY_TYPES=VNC`；该模式不加密，不建议暴露到公网。
