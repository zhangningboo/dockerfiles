### 编译、运行

```shell
$ docker build -t cuda-conda-zsh-v1 .
$ docker run -itd --gpus=all \
            -e DISPLAY=${REPLACE_YOUR_IP}:0.0 \
            --shm-size 16G \
            -p 9099:22 \
            -p 6066:6066 \
            -p 7077:7077 \
            --name cuda-conda-zsh \
            cuda-conda-zsh /bin/zsh
# 进入docker，安装桌面环境
$ sudo apt update
$ sudo apt install -y packagekit-gtk3-module libasound2 libdbus-glib-1-2
```
docker run -itd --gpus=all -e DISPLAY=192.168.3.44:0.0 --shm-size 16G -p 8088:22 -p 6066:6066 -p 7077:7077 --name chatglm cuda-conda-zsh /bin/zsh
