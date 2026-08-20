# ROS 2 Jazzy + noVNC + LXQt

该镜像基于 Ubuntu 24.04 Noble，使用 ROS 2 Jazzy、LXQt 桌面、TurboVNC 图形后端和 noVNC 1.7 Web 客户端。浏览器直接访问 `6080` 端口，无需安装 VNC Viewer，也无需挂载宿主机 `DISPLAY` / `.Xauthority` 或启用 `--privileged`。

LXQt 比 Fluxbox 拥有更完整的面板、应用菜单、文件管理器和系统设置；默认使用 Kvantum + Papirus 深色外观和轻量窗口阴影。它比 KDE Plasma/GNOME 更适合在 noVNC 和软件 OpenGL 环境中运行。

## 构建

ARM64（默认）：

```shell
docker build -t ros2-jazzy-novnc ./ros2-jazzy-no-vnc
```

AMD64：

```shell
docker build \
  --platform=linux/amd64 \
  --build-arg BASE_IMAGE=registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_amd64_ubuntu:24.04 \
  -t ros2-jazzy-novnc:amd64 \
  ./ros2-jazzy-no-vnc
```

## 启动和连接

```shell
docker run -d \
  --name ros2-jazzy-novnc \
  --shm-size=2g \
  -p 6080:6080 \
  -e VNC_PASSWORD='change-me' \
  ros2-jazzy-novnc
```

浏览器打开：

```text
http://<Docker 宿主机 IP>:6080/vnc.html?autoconnect=1&resize=remote
```

页面提示时输入 `VNC_PASSWORD`。窗口大小改变时，`resize=remote` 会让 LXQt 桌面跟随浏览器可视区域调整。

进入容器后可直接启动 RViz：

```shell
docker exec -it ros2-jazzy-novnc zsh
rviz2
```

VNC 口令至少 6 个字符；VNC 协议实际只使用前 8 个字符。也可以用 Docker secret 或挂载文件避免把口令直接写入命令行：

```shell
docker run -d \
  --name ros2-jazzy-novnc \
  --shm-size=2g \
  -p 6080:6080 \
  -v /path/to/vnc-password:/run/secrets/vnc-password:ro \
  -e VNC_PASSWORD_FILE=/run/secrets/vnc-password \
  ros2-jazzy-novnc
```

## 可配置项

| 环境变量 | 默认值 | 说明 |
| --- | --- | --- |
| `VNC_DISPLAY` | `:1` | VNC 显示号 |
| `VNC_PORT` | `5900 + 显示号` | VNC TCP 端口 |
| `VNC_GEOMETRY` | `1920x1080` | 桌面分辨率 |
| `VNC_DEPTH` | `24` | 色深 |
| `VNC_SECURITY_TYPES` | `VNC` | noVNC 兼容的 TurboVNC 认证类型 |
| `VNC_LOCALHOST` | `1` | TurboVNC 仅监听容器回环地址 |
| `NOVNC_PORT` | `6080` | noVNC HTTP/WebSocket 端口 |
| `NOVNC_CERT` / `NOVNC_KEY` | 空 | 同时设置时启用 HTTPS/WSS |
| `ENABLE_COMPOSITOR` | `1` | 启用 Picom 窗口阴影和淡入效果 |
| `LIBGL_ALWAYS_SOFTWARE` | `1` | 默认使用 Mesa 软件 OpenGL |

镜像默认设置 `DISPLAY=:1`，因此 `docker exec` 进入容器后可直接运行 RViz2。如果修改 `VNC_DISPLAY`，请同时将 `DISPLAY` 设为相同值。

TurboVNC 的 `5901` 默认只在容器回环地址上监听，不要将它映射到公网。默认 `6080` 是未加密 HTTP；公网使用时请挂载证书并设置 `NOVNC_CERT` / `NOVNC_KEY`，或在前端使用 HTTPS 反向代理。
