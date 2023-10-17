# 基础镜像
FROM nvidia/cuda:latest
ARG DEBIAN_FRONTEND=noninteractive

# 安装SSH服务器
# RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$distro/$arch/3bf863cc.pub
RUN mv /etc/apt/sources.list.d/cuda.list /etc/apt/sources.list.d/cuda.list.bak
RUN mv /etc/apt/sources.list.d/nvidia-ml.list /etc/apt/sources.list.d/nvidia-ml.list.bak

RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && apt-get clean && apt-get update

RUN apt-get install -y openssh-server ca-certificates vim curl wget net-tools iproute2 iputils-ping zsh git

RUN mv /etc/apt/sources.list.d/cuda.list.bak /etc/apt/sources.list.d/cuda.list
RUN mv /etc/apt/sources.list.d/nvidia-ml.list.bak /etc/apt/sources.list.d/nvidia-ml.list

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
RUN bash miniconda.sh -b -p /opt/conda
RUN rm miniconda.sh
ENV PATH="/opt/conda/bin:${PATH}"

# 设置SSH登录密码
RUN echo 'root:miniconda3' | chpasswd
RUN echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

# 声明容器会监听的端口
EXPOSE 22

# 启动容器时运行SSH服务
ENTRYPOINT service ssh start && /bin/zsh