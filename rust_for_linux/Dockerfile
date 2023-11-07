FROM debian:latest
# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive

# 创建一个普通用户并增加sudo权限，不需要密码
RUN apt update && apt install -y apt-transport-https ca-certificates
ADD sources.list /etc/apt/
RUN apt update \
    && apt install -y sudo net-tools openssh-server build-essential vim curl \
    && echo "set nu" >> ~/.vimrc\
    && useradd -m debian -s /bin/bash \
    && adduser debian sudo \
    && echo "debian ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers

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

# 设置时区
RUN echo "TZ='Asia/Shanghai'; export TZ" >> ~/.profile

# 设置SSH登录密码
RUN echo 'root:rustforlinux' | chpasswd
RUN echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

USER debian
WORKDIR /home/debian

# 安装ZSH
RUN sudo apt install -y git zsh
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \  
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && sed -i "s/robbyrussell/ys/" ~/.zshrc \
    && sed -i "s/plugins=(git.*)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/" ~/.zshrc \
    && sudo usermod -s /bin/zsh debian

# 安装 gui
# RUN sudo apt install -y packagekit-gtk3-module libasound2 libdbus-glib-1-2
ADD Firefox-latest-x86_64.tar.bz2 /opt/
RUN sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox

# 安装 cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh && echo "source \"$HOME/.cargo/env\"" >> ~/.zshrc
# 清除apt缓存
RUN sudo apt autoremove \
    && sudo apt clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

EXPOSE 22
CMD ["/bin/zsh"]