ARG BASE_IMAGE=registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_arm64_v8_ubuntu:26.04
FROM ${BASE_IMAGE}

# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH
ARG TURBOVNC_VERSION=3.3

RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's@//.*ports.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources \
    && apt-get update && apt-get upgrade -y && apt-get install -y ca-certificates

# SSH 服务（保留现有 root 登录配置）
RUN apt-get install -y vim openssh-server \
    && echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

# 基础工具
RUN apt-get install -y iputils-ping net-tools build-essential vim curl git git-lfs zsh lsb-release bash-completion

# TurboVNC 桌面及 RViz 所需的 X11/OpenGL 运行库。
# Fluxbox 不依赖 GTK/glycin 的嵌套沙箱，普通容器无需 --privileged 即可启动。
RUN apt-get install -y --no-install-recommends \
    dbus-x11 \
    fonts-dejavu-core \
    fonts-noto-cjk \
    fluxbox \
    libdbus-glib-1-2 \
    libgl1-mesa-dri \
    libglu1-mesa \
    libglx-mesa0 \
    mesa-utils \
    packagekit-gtk3-module \
    x11-xserver-utils \
    xterm

# TurboVNC 官方同时提供 amd64/arm64 包。固定版本和 SHA-256，避免供应链漂移。
RUN set -eux; \
    tvnc_arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "${tvnc_arch}" in \
        amd64) tvnc_sha256='3a9eaccd19bf6bb8e02df15734103c0388eec9db23b5e1654842628084ccb4b2' ;; \
        arm64) tvnc_sha256='5d0d7708f561ffd300391688438207de2efde530d5aef3a6dfb2f741fe61acd7' ;; \
        *) echo "Unsupported TurboVNC architecture: ${tvnc_arch}" >&2; exit 1 ;; \
    esac; \
    tvnc_deb="/tmp/turbovnc_${TURBOVNC_VERSION}_${tvnc_arch}.deb"; \
    curl -fL --retry 3 \
        -o "${tvnc_deb}" \
        "https://github.com/TurboVNC/turbovnc/releases/download/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_${tvnc_arch}.deb"; \
    echo "${tvnc_sha256}  ${tvnc_deb}" | sha256sum -c -; \
    apt-get install -y --no-install-recommends "${tvnc_deb}"; \
    rm -f "${tvnc_deb}"

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
    ros-lyrical-rviz2 \
    ros-lyrical-rviz-rendering \
    && chmod +x /opt/ros/lyrical/*.sh \
    && chmod +x /opt/ros/lyrical/*.bash \
    && chmod +x /opt/ros/lyrical/*.zsh \
    && chmod +x /opt/ros/lyrical/*.py \
    && echo "source /opt/ros/lyrical/setup.bash" >> /etc/profile

COPY entrypoint.sh /entrypoint.sh
COPY vnc-xstartup.sh /usr/local/bin/vnc-xstartup
RUN chmod +x /entrypoint.sh /usr/local/bin/vnc-xstartup

# 清除apt缓存
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root
COPY .gitconfig /root/.gitconfig

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

# VNC_DISPLAY=:1 默认对应 5901；22 保留给 SSH。
EXPOSE 22 5901

ENTRYPOINT ["/entrypoint.sh"]
