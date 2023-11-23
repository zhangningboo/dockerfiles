### Windows 下载 XServer
- 地址: `https://sourceforge.net/projects/vcxsrv/`
- 教程: `https://dev.to/darksmile92/run-gui-app-in-linux-docker-container-on-windows-host-4kde`
- 启动docker
```shell
$ docker build -t rust-for-linux .
$ docker run -itd -e DISPLAY=${REPLACE_YOUR_IP:0.0} --name rust-for-linux rust-for-linux /bin/zsh
```
### 下载firefox `https://www.mozilla.org/`
### 启动docker后设置环境变量 export DISPLAY=${REPLACE_YOUR_IP}:0.0
### 启动firefox
```shell
$ sudo apt install -y packagekit-gtk3-module libasound2 libdbus-glib-1-2
$ firefox
```
### 弹出firefox窗口