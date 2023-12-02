FROM ubuntu:jammy
# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive
# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics
# 清华源
RUN apt update && apt install -y ca-certificates
ADD sources.list /etc/apt/
# 创建ubuntu用户
RUN apt update \
    && apt install -y vim openssh-server sudo \
    && useradd -m ubuntu -s /bin/bash \
    && adduser ubuntu sudo \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers
# 基础工具
RUN apt install -y iputils*
# 用户
RUN echo 'root:ubuntu' | chpasswd \
    && echo 'ubuntu:ubuntu' | chpasswd \
    && echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config
# GUI
RUN apt install -y packagekit-gtk3-module libasound2 libdbus-glib-1-2
# ROS2源
RUN apt install -y curl gnupg2 \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu jammy main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && apt update && apt install -y locales \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && echo "export LANG=en_US.UTF-8" >> /etc/profile \
    && echo "TZ='Asia/Shanghai'; export TZ" >> /etc/profile
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
# 安装ROS
RUN apt install -y python3-colcon-common-extensions ros-humble-desktop-full \
    && chmod +x /opt/ros/humble/*.sh \
    && chmod +x /opt/ros/humble/*.bash \
    && chmod +x /opt/ros/humble/*.zsh \
    && chmod +x /opt/ros/humble/*.py \
    && echo "source /opt/ros/humble/setup.bash" >> /etc/profile
# 安装Moveit
RUN apt install -y ros-humble-moveit* \
    && apt install -y ros-humble-rviz*
# 安装ZSH
RUN apt update \
    && apt install -y net-tools build-essential vim curl git zsh lsb-release locales bash-completion
# 清除apt缓存
RUN apt autoremove \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*
USER ubuntu
WORKDIR /home/ubuntu
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \  
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && sed -i "s/robbyrussell/ys/" ~/.zshrc \
    && sed -i "s/plugins=(git.*)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/" ~/.zshrc \
    && echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc \
    && echo "setopt nonomatch" >>  ~/.zshrc \
    && echo "source /opt/ros/humble/setup.zsh" >> ~/.zshrc \
    && echo "set nu" >> ~/.vimrc
# 声明容器会监听的端口
EXPOSE 22
# 启动容器时运行SSH服务
ENTRYPOINT sudo service ssh start && /bin/zsh