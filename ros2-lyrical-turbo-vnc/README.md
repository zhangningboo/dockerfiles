# ROS 2 Lyrical + TurboVNC

该镜像在容器内启动 Fluxbox 桌面和 TurboVNC，无需把宿主机 `DISPLAY` 或 `.Xauthority` 挂载进容器，也无需 `--privileged`。默认 VNC 显示号为 `:1`，端口为 `5901`，连接加密/认证类型为 `TLSVnc`。

## 构建

ARM64（默认）：

```shell
docker build -t ros2-lyrical-turbovnc ./ros2-lyrica-turbo-vnc
```

AMD64：

```shell
docker build \
  --platform=linux/amd64 \
  --build-arg BASE_IMAGE=registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_amd64_ubuntu:26.04 \
  -t ros2-lyrical-turbovnc:amd64 \
  ./ros2-lyrica-turbo-vnc
```

## 启动和连接

```shell
docker run -d \
  --name ros2-lyrical-vnc \
  --shm-size=2g \
  -p 5901:5901 \
  -e VNC_PASSWORD='change-me' \
  ros2-lyrical-turbovnc
```

在 TurboVNC Viewer 中连接：

```text
<Docker 宿主机 IP>:5901
```

进入容器后可直接启动 RViz：

```shell
docker exec -it ros2-lyrical-vnc zsh
rviz2
```

VNC 口令至少 6 个字符；VNC 协议实际只使用前 8 个字符。也可以用 Docker secret 或挂载文件避免把口令直接写入命令行：

```shell
docker run -d \
  --name ros2-lyrical-vnc \
  --shm-size=2g \
  -p 5901:5901 \
  -v /path/to/vnc-password:/run/secrets/vnc-password:ro \
  -e VNC_PASSWORD_FILE=/run/secrets/vnc-password \
  ros2-lyrical-turbovnc
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

如果客户端不支持 `TLSVnc`，可在受信任网络中临时使用 `-e VNC_SECURITY_TYPES=VNC`；该模式不加密，不建议暴露到公网。
