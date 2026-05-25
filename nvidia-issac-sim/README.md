### 编译、运行

```shell
$ podman build -t nvidia-issac-sim:13.2.1-cudnn-devel-ubuntu24.04 .

$ xhost +local:podman@
non-network local connections being added to access control list
$ echo $DISPLAY
:1
$ podman run -itd \
  --device nvidia.com/gpu=all \
  -e DISPLAY=:1 \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -p 2222:22 \
  --hostname nvidia-isaac-smi \
  --name nvidia-isaac-smi-cuda-13.2.1-ubuntu24.04 \
  nvidia-issac-sim:13.2.1-cudnn-devel-ubuntu24.04 \
  zsh
```

nvidia-issac-sim:13.2.1-cudnn-devel-ubuntu24.04

docker run --name isaac-sim --entrypoint bash -it --device nvidia.com/gpu=all --rm --network=host \
     -e "ACCEPT_EULA=Y" \
     -e "PRIVACY_CONSENT=Y" \
     -v ~/podman-isaac-sim/cache/main:/isaac-sim/.cache \
     -v ~/podman-isaac-sim/cache/computecache:/isaac-sim/.nv/ComputeCache \
     -v ~/podman-isaac-sim/logs:/isaac-sim/.nvidia-omniverse/logs \
     -v ~/podman-isaac-sim/config:/isaac-sim/.nvidia-omniverse/config \
     -v ~/podman-isaac-sim/data:/isaac-sim/.local/share/ov/data \
     -v ~/podman-isaac-sim/pkg:/isaac-sim/.local/share/ov/pkg \
     -v /etc/sudoers:/root/etc/sudoers \
     nvcr.io/nvidia/isaac-sim:6.0.0-dev2
