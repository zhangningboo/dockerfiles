# # 基础镜像
# FROM ubuntu:22.04
# ENV LANG C.UTF-8

# # 安装SSH服务器
# RUN apt update && apt install -y ca-certificates
# # 换源
# ADD sources.list /etc/apt/
# # 基础环境


# RUN apt update && apt install -y openssh-server vim curl net-tools iproute2 iputils-ping zsh git make gcc g++ gdb

# # RUN sh -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \  
#     && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
#     && sed -i "s/robbyrussell/ys/" ~/.zshrc \
#     && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
#     && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
#     && sed -i "s/plugins=(git.*)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/" ~/.zshrc

# # 设置SSH登录密码
# RUN echo 'root:rustforlinux' | chpasswd
# RUN echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

# # 声明容器会监听的端口
# EXPOSE 22

# # 启动容器时运行SSH服务
# ENTRYPOINT ["/bin/zsh"]

# # 编译：docker build -t rust_for_linux .

FROM ubuntu:22.04

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
RUN sudo apt install -y packagekit-gtk3-module libasound2 libdbus-glib-1-2

# 清除apt缓存
RUN sudo apt autoremove \
    && sudo apt clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

EXPOSE 22
ENTRYPOINT /bin/zsh

# windows中放开vserver的防火墙
# 编译: docker build -t rust_for_linux .
# 启动: docker run -itd -e DISPLAY=${HOST_IP}:0.0 --name rust_for_linux rust_for_linux /bin/zsh
