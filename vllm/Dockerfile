# 选用一个基础镜像，就像是选择一个好的起点，这里我们用了 NVIDIA 的 CUDA 镜像，因为我们要做的事情需要大量的计算力。
ARG base=nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

# 从我们之前选好的“起点”开始。
FROM ${base}

# 设定 Conda 版本，就像是告诉厨师，我们今天要用哪种香料进行烹饪。
# ARG CONDA_VERSION=py311_23.11.0-2
ARG CONDA_VERSION=latest

# 设定 Miniconda 下载地址，就像是选定了一个信得过的菜市场。
ARG MINICONDA_BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/


# 设置环境变量，这有点像是设定厨房的温度和湿度，让一切都适宜。
ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN apt update && apt install -y apt-transport-https ca-certificates
ADD sources.list /etc/apt/
RUN apt update \
    && apt install -y sudo net-tools openssh-server build-essential vim curl \
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
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \  
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && sed -i "s/robbyrussell/ys/" ~/.zshrc \
    && sed -i "s/plugins=(git.*)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/" ~/.zshrc 

# 重新绑定home与end键
RUN echo "# Home\nbindkey '\e[1~' beginning-of-line\n# End\nbindkey '\e[4~' end-of-line" >> ~/.zshrc

# conda
RUN wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
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

# 设置 Python 的环境变量。
ENV PYTHON_PREFIX=/opt/conda/bin

# 更新 Python、pip 的可执行路径，就像是把这把瑞士军刀挂在腰间，随时准备使用。
RUN update-alternatives --install /usr/bin/python python ${PYTHON_PREFIX}/python 1 && \
    update-alternatives --install /usr/bin/python3 python3 ${PYTHON_PREFIX}/python3 1 && \
    update-alternatives --install /usr/bin/pip pip ${PYTHON_PREFIX}/pip 1 && \
    update-alternatives --install /usr/bin/pip3 pip3 ${PYTHON_PREFIX}/pip3 1

# 创建工作目录，就像是在厨房里清理出一块干净的操作台。
RUN mkdir -p /workspace

# 配置 pip 使用国内源。
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 安装 transformers、accelerate 等 Python 包，这些就像是我们的厨房里的调料，每种都是做出美味必不可少的。
RUN pip3 install transformers==4.32.0 accelerate tiktoken einops scipy transformers_stream_generator==0.0.4 peft deepspeed fschat

# 特殊的包有时需要单独处理，就像是某些调料需要特别的保存方式。
# RUN pip3 install flash-attention
RUN pip3 install xformers --no-deps

# 安装 vllm 包，并清除 pip 缓存，保持厨房整洁。
RUN pip3 install vllm  && \
    pip3 cache purge

# 设置工作目录，告诉大家：“这里是我的领地！”
WORKDIR /workspace

# 设置入口点，就像是在门上挂了个欢迎牌，告诉客人：“太君，this way”
ENTRYPOINT [ "python", "-m", "vllm.entrypoints.openai.api_server","--host", "0.0.0.0", "--port", "8080"]