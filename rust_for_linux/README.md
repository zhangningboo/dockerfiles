## 宿主机操作
### Windows 下载 XServer
- 地址: `https://sourceforge.net/projects/vcxsrv/`
- 教程: `https://dev.to/darksmile92/run-gui-app-in-linux-docker-container-on-windows-host-4kde`

### 下载firefox `https://www.mozilla.org/`，放入rust_for_linux文件夹下
### 宿主机中编译镜像：docker build -t rust_for_linux_image .
### 宿主机中启动容器
```shell
docker run -itd -e DISPLAY=${HOST_IP}:0.0 --privileged --platform linux/amd64 --name rust_for_linux_container rust_for_linux_image /bin/zsh
```
## docker容器操作
### 设置环境变量
```shell
$ export DISPLAY=${HOST_IP}:0.0
$ export GIT_USER_NAME=${YOUR_GIT_NAME}
```
### 安装组件：
```shell
$ sudo apt update && sudo apt install -y packagekit-gtk3-module libasound2 libdbus-glib-1-2
```
### 启动firefox弹出窗口
```shell
$ firefox
```
### qemu编译(自行下载编译)
```shell
$ mkdir build && cd build
$ sudo apt install libslirp-dev
$ ../configure --target-list=x86_64-softmmu,x86_64-linux-user --enable-slirp --enable-user
```

### qemu
```shell
$ sudo apt update && sudo apt install qemu-system-x86
$ qemu-system-x86_64 --version

QEMU emulator version 7.2.5 (Debian 1:7.2+dfsg-7+deb12u2)
Copyright (c) 2003-2022 Fabrice Bellard and the QEMU Project developers

```

### 文件系统
参考:https://blog.arg.pub/2022/10/03/os/%E4%BD%BF%E7%94%A8Docker%E7%BC%96%E8%AF%9132%E4%BD%8DLinux%E5%86%85%E6%A0%B8%E5%B9%B6%E5%9C%A8Qemu%E4%B8%AD%E8%BF%90%E8%A1%8C/index.html
```shell
$ qemu-img create -f raw disk.raw 2048M
Formatting 'disk.raw', fmt=raw size=2147483648
$ mkfs -t ext4 ./disk.raw
$ mkdir img && sudo mount -o loop ./disk.raw ./img
$ sudo make modules_install INSTALL_MOD_PATH=./img
$ cd linux
$ sudo make modules_install INSTALL_MOD_PATH=../src_e1000/img
# 已经修改了 src_e1000/build_img.sh
# 重新进入busy目录下
$ make && sudo make CONFIG_PREFIX=/home/debian/cicv-r4l-${GIT_USER_NAME}/src_e1000/img install
$ cd _install
$ sudo apt install cpio && find . | cpio -o --format=newc > ../rootfs.img

$ cd src_e1000 && sudo ./build_img.sh
```

