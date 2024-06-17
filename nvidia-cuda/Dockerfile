# 基础镜像B1kOquEGY6y9*t^%
FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04
# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive

# 创建一个普通用户并增加sudo权限，不需要密码
RUN apt update && apt install -y apt-transport-https ca-certificates
ADD sources.list /etc/apt/
RUN apt update \
    && apt install -y sudo net-tools openssh-server build-essential vim curl libssl-dev libcurl4-openssl-dev libcurl4 \
    && echo "set nu" >> ~/.vimrc\
    && useradd -m ubuntu -s /bin/bash \
    && adduser ubuntu sudo \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers

RUN apt install -y \
    build-essential libtool texinfo \
    gzip zip unzip patchutils \
    cmake ninja-build automake bison flex gperf \
    grep sed gawk bc \
    zlib1g-dev libexpat1-dev libmpc-dev libncurses-dev \
    libglib2.0-dev libfdt-dev libpixman-1-dev libelf-dev libssl-dev \
    clang-format clang-tidy clang-tools clang clangd \
    libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev \
    libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm python3-clang

# cuda key
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/7fa2af80.pub
# 切换源
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && apt-get clean && apt-get update
# 安装服务
RUN apt-get install -y openssh-server ca-certificates vim curl wget net-tools iproute2 iputils-ping zsh git ntpdate libopenmpi-dev

# 设置时区
RUN echo "TZ='Asia/Shanghai'; export TZ" >> ~/.profile

# 设置SSH登录密码
RUN echo 'root:miniconda3' | chpasswd
RUN echo 'ubuntu:miniconda3' | chpasswd
RUN echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

USER ubuntu
WORKDIR /home/ubuntu

# 安装ZSH
RUN sudo apt install -y git zsh
RUN git clone https://mirror.ghproxy.com/https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \
    && git clone https://mirror.ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://mirror.ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && sed -i "s/robbyrussell/ys/" ~/.zshrc \
    && sed -i "s/plugins=(git.*)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/" ~/.zshrc

# 重新绑定home与end键
RUN echo "# Home\nbindkey '\e[1~' beginning-of-line\n# End\nbindkey '\e[4~' end-of-line" >> ~/.zshrc

# conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
    && sudo bash miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh \
    && sudo chown -R ubuntu:ubuntu /opt/conda

ENV PATH="/opt/conda/bin:${PATH}"
# pip 清华源
RUN zsh && conda init --all && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
# conda清华源
ADD .condarc .

RUN sudo apt autoremove \
    && sudo apt clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

# 声明容器会监听的端口
EXPOSE 22

# 启动容器时运行SSH服务
ENTRYPOINT sudo service ssh start && /bin/zsh