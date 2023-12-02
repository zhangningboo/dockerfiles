## 编译&启动
```shell
$ docker build -t ros2-humble-v1 .
$ docker run -itd --network=host --privileged --group-add video --gpus=all --isolation=process --name ros2-humble-v1 ros2-humble-v1 /bin/zsh
$ docker run -itd --network=host --privileged --group-add video --gpus=all -e DISPLAY=${REPLACE_YOUR_IP}:0.0 --shm-size 16G --name ros2-humble-v1 ros2-humble-v1 /bin/zsh
docker run -itd --network=host --privileged --gpus=all -e DISPLAY=192.168.3.2:0.0 --shm-size 16G --name ros2-humble-v5 ros2-humble-v5 /bin/zsh
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
$ sudo echo "/opt/ros/humble/lib" >> /etc/ld.so.conf
$ sudo ldconfig
```