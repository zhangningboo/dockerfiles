# FROM registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_amd64_ubuntu:26.04
FROM registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_arm64_v8_ubuntu:26.04
# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive

RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's@//.*ports.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources \
    && apt-get update && apt-get upgrade -y && apt-get install -y ca-certificates

# 创建ubuntu用户
RUN apt-get install -y vim openssh-server sudo \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers \
    && echo 'root:ubuntu' | chpasswd \
    && echo 'ubuntu:ubuntu' | chpasswd \
    && echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

# 基础工具
RUN apt-get install -y iputils* net-tools build-essential vim curl git git-lfs zsh lsb-release bash-completion

# GUI
RUN apt-get install -y packagekit-gtk3-module libdbus-glib-1-2

RUN apt-get install -y locales \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && echo "export LANG=en_US.UTF-8" >> /etc/profile \
    && echo "TZ='Asia/Shanghai'; export TZ" >> /etc/profile
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

RUN apt-get install -y software-properties-common \
    && add-apt-repository universe

# ROS2源
RUN export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}') \
    && curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" \
    && dpkg -i /tmp/ros2-apt-source.deb \
    && apt-get update

# 安装ROS
RUN apt-get install -y python3-colcon-common-extensions ros-dev-tools ros-lyrical-ros-base \
    python3-pip \
    ros-lyrical-tf2-ros \
    ros-lyrical-image-transport \
    ros-lyrical-vision-msgs \
    ros-lyrical-urdf-launch \
    ros-lyrical-foxglove-bridge \
    && chmod +x /opt/ros/lyrical/*.sh \
    && chmod +x /opt/ros/lyrical/*.bash \
    && chmod +x /opt/ros/lyrical/*.zsh \
    && chmod +x /opt/ros/lyrical/*.py \
    && echo "source /opt/ros/lyrical/setup.bash" >> /etc/profile

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 清除apt缓存
RUN apt-get autoremove \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
USER ubuntu
WORKDIR /home/ubuntu
ADD .gitconfig /home/ubuntu/

RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && sed -i "s/robbyrussell/ys/" ~/.zshrc \
    && sed -i "s/plugins=(git.*)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/" ~/.zshrc \
    && echo "source /opt/ros/lyrical/setup.bash" >> ~/.bashrc \
    && echo "setopt nonomatch" >>  ~/.zshrc \
    && echo "source /opt/ros/lyrical/setup.zsh" >> ~/.zshrc \
    && echo "set nu" >> ~/.vimrc

    # 声明容器会监听的端口
EXPOSE 22 8765

ENTRYPOINT ["/entrypoint.sh"]