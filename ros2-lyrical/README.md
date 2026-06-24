## 编译&启动
```shell
$ docker build -t ros2-lyrical-devel-v1 .
$ docker run -itd --network=host --privileged --group-add video --gpus=all --isolation=process --name ros2-lyrical-v1 ros2-lyrical-v1 /bin/zsh
$ docker run -itd --privileged -e DISPLAY=${REPLACE_YOUR_IP}:0.0 --shm-size 16G --name ros2-lyrical-v1 ros2-lyrical-v1 /bin/zsh
$ docker run -itd --privileged -e DISPLAY=192.168.3.2:0.0 --shm-size 16G --name ros2-lyrical-v1 ros2-lyrical-v1 /bin/zsh
```
更换网络后，进入容器，重新修改环境变量`DISPLAY`，让其指向新`ip`即可：`export DISPLAY=${REPLACE_YOUR_IP}:0.0`
## GUI
```shell
$ sudo rviz2
```
## 报错
- `Authorization required, but no authorization protocol specified`
```shell
$ sudo rviz2
```
- `error while loading shared libraries: libOgreMain.so.1.12.1: cannot open shared object file: No such file or directory`
```shell
$ git clone https://github.com/OGRECave/ogre.git
$ cd ogre && git checkout v1.12.1 && mkdir build && cd build && cmake ..
$ make -j$(nproc) && sudo make install
$ sudo echo "/usr/local/lib" >> /etc/ld.so.conf
$ sudo ldconfig
```
- `rviz2: error while loading shared libraries: librviz_rendering.so: cannot open shared object file: No such file or directory`
```shell
$ sudo echo "/opt/ros/lyrical/lib" >> /etc/ld.so.conf
$ sudo ldconfig
```

```shell
$ container build -t ros2-lyrical:ubuntu_arm64_26.04 .
$ xhost +local:
$
$ container run -it \
  -e DISPLAY=$DISPLAY \
  -v $HOME/.Xauthority:/home/ubuntu/.Xauthority:rw \
  -e XAUTHORITY=/home/ubuntu/.Xauthority \
  --name my-vnc-container \
  ros2-lyrical:ubuntu_arm64_26.04 zsh

# 1. 安装基础桌面环境和 VNC 服务
RUN apt-get update && apt-get install -y \
    dbus-x11 xfce4 xfce4-goodies \
    tightvncserver \
    x11vnc \
    xvfb

# 2. 设置 VNC 连接密码 (以 password 为例)
RUN mkdir ~/.vnc && x11vnc -storepasswd 123456 ~/.vnc/passwd

# 3. 容器启动时，创建虚拟显示并启动 VNC
CMD Xvfb :1 -screen 0 1024x768x16 & \
    export DISPLAY=:1 && \
    sudo xfce4-session & \
    sudo x11vnc -forever -usepw -display :1
```

```shell

$ podman build -t ros2-lyrical:ubuntu_arm64_26.04 .
$ podman run --rm -it \
  --network host \
  -e DISPLAY=host.containers.internal:0 \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  ros2-lyrical:ubuntu_arm64_26.04 zsh

$ sudo apt install libglx-mesa0 libgl1-mesa-dri

$ podman build -t registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_arm64_v8_ros:ros-lyrical-ros-base .
$ podman run --rm -it \
  --network host \
  -e DISPLAY=host.containers.internal:0 \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v $HOME/.Xauthority:/home/ubuntu/.Xauthority:rw \
  registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_arm64_v8_ros:ros-lyrical-ros-base zsh
$ sudo apt update
$ sudo apt install ros-$ROS_DISTRO-rviz2 ros-$ROS_DISTRO-rviz-rendering libogre-1.12-dev
```

