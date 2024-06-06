# 基础镜像B1kOquEGY6y9*t^%
FROM cuda-conda-zsh-v1
# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive

USER ubuntu
WORKDIR /home/ubuntu

RUN git clone -b r23.10 https://mirror.ghproxy.com/https://github.com/triton-inference-server/server.git && cd server && ./build.py -v --no-container-build --build-dir=`pwd`/build --enable-all


# 声明容器会监听的端口
EXPOSE 22

# 启动容器时运行SSH服务
ENTRYPOINT sudo service ssh start && /bin/zsh


