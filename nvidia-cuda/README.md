### 编译、运行

```shell
$ docker build -t nvidia-cuda-conda-zsh .
$ docker run -itd --gpus=all --shm-size 16G -p 9099:22 -p 6066:6066 -p 7077:7077 --name cuda-conda-zsh nvidia-cuda-conda-zsh /bin/zsh
```