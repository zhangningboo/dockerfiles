```shell
$ docker build -t ros1-melodic .
$ docker network create --subnet=192.168.1.0/24 mynetwork
$ docker run --network=mynetwork --ip=192.168.1.123 -it your_image
$ docker run -itd --privileged --group-add video --gpus=all --isolation=process --device="class/GUID_DEVINTERFACE_DISK" --name ros-melodic rocker /bin/bash
```