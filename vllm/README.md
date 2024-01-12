### 编译、运行

```shell
$ docker build -t vllm-server .

$ docker run \
  -itd \
  --name vllm \
  --gpus all \
  --ipc=host \
  -p 10080:8080 \
  -v :/Qwen-7B-Chat \
  --tensor-parallel-size 2 \
  --model /Qwen-7B-Chat \
  --trust-remote-code \
  vllm-server \
  /bin/zsh

# 进入docker，安装桌面环境
$ sudo apt update
$ sudo apt install -y packagekit-gtk3-module libasound2 libdbus-glib-1-2
```
