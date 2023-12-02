```shell
$ docker build -t ros1-melodic .
$ docker run -itd --privileged --group-add video --gpus=all --isolation=process --device="class/GUID_DEVINTERFACE_DISK" --name ros-melodic rocker /bin/bash
```