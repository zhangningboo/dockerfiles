### 编译
```shell
$ docker build -t ubuntu-arm64 .
```
### 启动示例
```shell
$ docker run -it --privileged --gpus=all -e DISPLAY=192.168.3.2:0.0 --shm-size 16G --name ros1-noetic-v1 ros1-noetic-v1 /bin/zsh

docker run -it --privileged --gpus=all -e DISPLAY=192.168.3.2:0.0 --shm-size 16G --name ros111 osrf/ros:noetic-desktop-bionic bash
```

### 自定义网络
```shell
$ docker network create --subnet=192.168.1.0/24 docker_net
$ docker run -it --privileged --network=docker_net -e DISPLAY=192.168.3.2:0.0 --shm-size 16G --name ros1-noetic-v1 ros1-noetic-v1 /bin/zsh
$ docker run -it --privileged --network=docker_net --ip=192.168.1.123 -e DISPLAY=192.168.3.2:0.0 --shm-size 16G --name ros1-noetic-v1 ros1-noetic-v1 /bin/zsh
```

### 错误
- `libGL error: failed to load driver: swrast`
```shell
export QMLSCENE_DEVICE=softwarecontext
export LIBGL_ALWAYS_INDIRECT=y
```
- `1362 segmentation fault  rviz`

docker run -itd --privileged -p 6022:22 --name sophon_dev ubuntu:18.04_arm64 bash
53f9b2fd435ff9368c44d9fcabf6f5d2a1dee99034217e48213f02c3369b80c9
