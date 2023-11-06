FROM ubuntu:22.04
# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive

# 创建一个普通用户并增加sudo权限，不需要密码
RUN apt update && apt install -y ca-certificates
ADD sources.list /etc/apt/
RUN apt update \
    && apt install -y sudo net-tools openssh-server build-essential vim curl \
    && echo "set nu" >> ~/.vimrc\
    && useradd -m ubuntu -s /bin/bash \
    && adduser ubuntu sudo \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers

# 设置时区
RUN echo "TZ='Asia/Shanghai'; export TZ" >> ~/.profile

# 设置SSH登录密码
RUN echo 'root:miniconda3' | chpasswd
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
    && sed -i "s/plugins=(git.*)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/" ~/.zshrc \
    && sudo usermod -s /bin/zsh ubuntu

# 安装 gui
# RUN sudo apt install -y packagekit-gtk3-module libasound2 libdbus-glib-1-2
ADD Firefox-latest-x86_64.tar.bz2 /opt/
RUN sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox

# 清除apt缓存
RUN sudo apt autoremove \
    && sudo apt clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

EXPOSE 22
ENTRYPOINT /bin/zsh

# windows中放开vserver的防火墙
# 编译: docker build -t rust_for_linux .
# 启动: docker run -itd -e DISPLAY=${HOST_IP}:0.0 --name rust_for_linux rust_for_linux /bin/zsh
