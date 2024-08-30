FROM ubuntu:18.04
# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive
# 清华源
RUN apt update && apt install -y ca-certificates vim
ADD sources.list /etc/apt/
# 创建ubuntu用户
RUN apt update \
    && apt install -y openssh-server sudo \
    && service ssh start \
    && useradd -m ubuntu -s /bin/bash \
    && adduser ubuntu sudo \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers
# 基础工具
RUN apt install -y iputils* mesa-utils telnet tree net-tools build-essential vim curl git zsh lsb-release locales bash-completion

# 用户
RUN echo 'root:ubuntu' | chpasswd \
    && echo 'ubuntu:ubuntu' | chpasswd \
    && echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

# 中文环境
RUN apt install -y language-pack-zh*  && localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# 安装ZSH
RUN apt update \
    && apt install -y net-tools build-essential vim curl git zsh lsb-release locales bash-completion
# 清除apt缓存
RUN apt autoremove \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*
USER ubuntu
WORKDIR /home/ubuntu
RUN git clone https://mirror.ghproxy.com/https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \
    && git clone https://mirror.ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://mirror.ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && sed -i "s/robbyrussell/ys/" ~/.zshrc \
    && sed -i "s/plugins=(git.*)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/" ~/.zshrc \
    && echo "setopt nonomatch" >>  ~/.zshrc \
    && echo "set nu" >> ~/.vimrc
# 声明容器会监听的端口
EXPOSE 22
# 启动容器时运行SSH服务
ENTRYPOINT sudo service ssh start && /bin/zsh