### 编译、运行

```shell
$ docker build -t cuda-conda-zsh-v1 .
$ docker run -itd --gpus=all \
            -e DISPLAY=${REPLACE_YOUR_IP}:0.0 \
            --shm-size 16G \
            -p 9099:22 \
            -p 6066:6066 \
            -p 7077:7077 \
            --name cuda-conda-zsh-v1 \
            cuda-conda-zsh /bin/zsh
# 进入docker，安装桌面环境
$ sudo apt update
$ sudo apt install -y packagekit-gtk3-module libasound2 libdbus-glib-1-2
$ export LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64:${LD_LIBRARY_PATH}
$ export CUDA_HOME=/usr/local/cuda-12.6
$ export PATH=${CUDA_HOME}/bin:${PATH}
$ nvidia-smi --query-gpu=compute_cap --format=csv
$ make COMPUTE=8.0
$ gpu_burn -m 95% -tc -d 3600
```
docker run -itd --gpus=all -e DISPLAY=192.168.3.44:0.0 --shm-size 16G -p 8088:22 -p 6066:6066 -p 7077:7077 --name chatglm cuda-conda-zsh /bin/zsh
docker run -itd --gpus=all --shm-size 16G -p 8088:22 -p 6066:6066 -p 7077:7077 -p 8000:8000 -p 8001:8001 -p 8002:8002 --name dev cuda-conda-zsh-v1 /bin/zsh

sudo apt install libssl-dev libcurl4-openssl-dev libcurl4
docker run -itd --gpus=all --shm-size 16G -p 9099:22 --name aky cuda-conda-zsh-v1 /bin/zsh

docker run -itd --gpus=all --shm-size 128G -p 7422:22 -p 7480:8080 -p 7481:8081 -p 7482:8082 -p 7483:8083 -v /data/zhangningbo:/opt --name cuda11.8.0-cudnn8-conda-zsh-v1 nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 /bin/bash


docker run -itd --gpus=all --shm-size 128G -p 8088:22 -p 6066:6066 -p 7077:7077 --name yolox_obb pytorch/pytorch:1.9.0-cuda10.2-cudnn7-devel /bin/bash


docker run -itd --gpus=all --shm-size 128G -p 10099:22 cuda_11.7.1-conda-zsh-v1 --name wyz_cuda_11.7.1-conda-zsh-v1 zsh

docker run -itd --gpus=all --shm-size 128G -p 10088:22  -v $PWD:/workspace cuda_11.7.1-conda-zsh-v1 --name sophon_cuda_11.7.1-conda-zsh-v1 zsh


docker run -itd --gpus=all --shm-size 128G -p 2322:22 -v /home/omnisky/YOLOX_OBB:/opt/YOLOX_OBB  --name wyz_yolox_obb yolox_obb:0.1 /bin/bash
docker start 504ff012fda7  # 服务器断电重启后，容器没有自动启动执行
docker exec -it 504ff012fda7 /bin/bash  # 在终端进入容器使用

docker exec -it wyz_yolox_obb /bin/bash


torchvision                   0.11.0      py37_cu113  pytorch
