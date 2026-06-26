# FROM registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_amd64_cuda:13.0.2-cudnn-devel-ubuntu22.04
FROM registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_arm64_v8_ubuntu:22.04

# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive
# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list \
    && sed -i 's@//.*ports.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list \
    && apt-get update && apt-get install -y ca-certificates

# 创建ubuntu用户
RUN apt-get install -y vim openssh-server sudo \
    && useradd -m ubuntu -s /bin/bash \
    && adduser ubuntu sudo \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers \
    && echo 'root:ubuntu' | chpasswd \
    && echo 'ubuntu:ubuntu' | chpasswd \
    && echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

# 基础工具
RUN apt-get install -y iputils* net-tools build-essential vim git git-lfs zsh lsb-release locales bash-completion

# GUI
RUN apt-get install -y packagekit-gtk3-module libasound2 libdbus-glib-1-2 \
    xvfb \
    x11vnc \
    fluxbox \
    supervisor \
    wget \
    curl \
    git \
    python3-pip

# ROS2源
RUN apt-get install -y curl gnupg2 \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://mirrors.ustc.edu.cn/ros2/ubuntu $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && apt-get update && apt-get install -y locales \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && echo "export LANG=en_US.UTF-8" >> /etc/profile \
    && echo "TZ='Asia/Shanghai'; export TZ" >> /etc/profile
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# 安装ROS
RUN apt-get install -y python3-colcon-common-extensions ros-humble-ros-base \
    python3-pip \
    ros-humble-tf2-ros \
    ros-humble-image-transport \
    ros-humble-vision-msgs \
    ros-humble-urdf-launch \
    ros-humble-foxglove-bridge \
    && chmod +x /opt/ros/humble/*.sh \
    && chmod +x /opt/ros/humble/*.bash \
    && chmod +x /opt/ros/humble/*.zsh \
    && chmod +x /opt/ros/humble/*.py \
    && echo "source /opt/ros/humble/setup.bash" >> /etc/profile

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 清除apt-get缓存
RUN apt-get autoremove \
    && apt-get clean -y \
    && rm -rf /var/lib/apt-get/lists/*

USER ubuntu
WORKDIR /home/ubuntu
ADD .gitconfig /home/ubuntu/
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

EXPOSE 22 8765

ENTRYPOINT ["/entrypoint.sh"]