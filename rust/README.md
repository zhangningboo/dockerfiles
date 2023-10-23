### 编译、运行

```shell
$ docker build -t rust-zsh .
$ docker run -itd --shm-size 16G -p 9010:22 -p 6010:6010 -p 7010:7010 --name rust-zsh-runtime rust-zsh /bin/zsh
```