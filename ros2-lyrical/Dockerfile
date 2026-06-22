FROM registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_amd64_ubuntu:26.04
# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y ca-certificates \
    && sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list
# 创建ubuntu用户
RUN apt update \
    && apt install -y vim openssh-server sudo \
    && adduser ubuntu sudo \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers
# 基础工具
RUN apt install -y iputils*
# 用户
RUN echo 'root:ubuntu' | chpasswd \
    && echo 'ubuntu:ubuntu' | chpasswd \
    && echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config
# GUI
RUN apt install -y packagekit-gtk3-module libdbus-glib-1-2

RUN apt update && apt install -y locales \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && echo "export LANG=en_US.UTF-8" >> /etc/profile \
    && echo "TZ='Asia/Shanghai'; export TZ" >> /etc/profile
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
# 安装ROS

RUN apt install -y software-properties-common \
    && add-apt-repository universe
# ROS2源
RUN apt update \
    && export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}') \
    && curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" \
    && dpkg -i /tmp/ros2-apt-source.deb \
    && apt update \
    && apt upgrade -y

RUN apt install -y python3-colcon-common-extensions ros-dev-tools ros-lyrical-desktop \
    && chmod +x /opt/ros/lyrical/*.sh \
    && chmod +x /opt/ros/lyrical/*.bash \
    && chmod +x /opt/ros/lyrical/*.zsh \
    && chmod +x /opt/ros/lyrical/*.py \
    && echo "source /opt/ros/lyrical/setup.bash" >> /etc/profile

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
    && echo "source /opt/ros/lyrical/setup.bash" >> ~/.bashrc \
    && echo "setopt nonomatch" >>  ~/.zshrc \
    && echo "source /opt/ros/lyrical/setup.zsh" >> ~/.zshrc \
    && echo "set nu" >> ~/.vimrc
ADD .gitconfig /home/ubuntu/
# 声明容器会监听的端口
EXPOSE 22
# 启动容器时运行SSH服务
ENTRYPOINT sudo service ssh start && /bin/zsh