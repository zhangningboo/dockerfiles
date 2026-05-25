# 基础镜像
FROM registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_amd64_cuda:13.2.1-cudnn-devel-ubuntu24.04
# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive

# 创建一个普通用户并增加sudo权限，不需要密码
RUN apt update && apt install -y apt-transport-https ca-certificates
ADD ubuntu.sources /etc/apt/sources.list.d/
RUN apt update \
    && apt install -y sudo \
    && echo "set nu" >> ~/.vimrc \
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
    libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm python3-clang \
    openssh-server ca-certificates vim curl libcurl4 libcurl4-openssl-dev wget net-tools \
    iproute2 iputils-ping zsh git git-lfs ntpdate libopenmpi-dev

# 设置时区
RUN echo "TZ='Asia/Shanghai'; export TZ" >> ~/.profile

# 设置SSH登录密码
RUN echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

RUN apt install -y gcc-11 g++-11 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 200 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 200 \
    && echo `gcc --version`

USER ubuntu
WORKDIR /home/ubuntu
ADD .gitconfig /home/ubuntu/.gitconfig
# 安装Oh My Zsh和插件
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && sed -i "s/robbyrussell/ys/" ~/.zshrc \
    && sed -i "s/plugins=(git.*)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/" ~/.zshrc

RUN UV_DOWNLOAD_PROXY="https://gh-proxy.com" \
    && UV_PYPI_MIRROR="https://mirrors.ustc.edu.cn/pypi/simple" \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && echo "export UV_DOWNLOAD_PROXY=https://gh-proxy.com" >> ~/.zshrc \
    && echo "export UV_PYPI_MIRROR=https://mirrors.ustc.edu.cn/pypi/simple" >> ~/.zshrc

# RUN git clone https://github.com/isaac-sim/IsaacSim.git isaacsim \
#     && cd isaacsim \
#     && git lfs install \
#     && git lfs pull \
#     && /home/ubuntu/.local/bin/uv venv --python 3.11 --seed --managed-python \
#     && . .venv/bin/activate \
#     && ./build.sh

RUN sudo apt autoremove \
    && sudo apt clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

# 声明容器会监听的端口
EXPOSE 22

# 启动容器时运行SSH服务
ENTRYPOINT sudo service ssh start && /bin/zsh
