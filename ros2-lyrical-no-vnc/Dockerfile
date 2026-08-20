ARG BASE_IMAGE=registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_arm64_v8_ubuntu:26.04
FROM ${BASE_IMAGE}

# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH
ARG TURBOVNC_VERSION=3.3
ARG NOVNC_VERSION=1.7.0
ARG NOVNC_SHA256=b1003a11b6e6e8d8f7f5e5586daae7f8ca651d8aee0aa155ff9ac841c48f52c6

RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's@//.*ports.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources \
    && apt-get update && apt-get upgrade -y && apt-get install -y ca-certificates

# SSH 服务（保留现有 root 登录配置）
RUN apt-get install -y vim openssh-server \
    && echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

# 基础工具
RUN apt-get install -y iputils-ping net-tools build-essential vim curl git git-lfs zsh lsb-release bash-completion

# LXQt 2 桌面、noVNC 代理及 RViz 所需的 X11/OpenGL 运行库。
# LXQt 基于 Qt，可避免 GTK/glycin 在受限容器中启动嵌套沙箱的问题。
RUN apt-get install -y --no-install-recommends \
    arc-theme \
    breeze-icon-theme \
    dbus-x11 \
    fonts-dejavu-core \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    libdbus-glib-1-2 \
    libgl1-mesa-dri \
    libglu1-mesa \
    libglx-mesa0 \
    lxqt-core \
    mesa-utils \
    openbox \
    papirus-icon-theme \
    picom \
    qt6-style-kvantum \
    websockify \
    x11-xserver-utils \
    xdg-utils

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

# noVNC 是纯静态 Web 客户端；websockify 来自 Ubuntu 安全更新源。
RUN set -eux; \
    novnc_archive="/tmp/novnc-v${NOVNC_VERSION}.tar.gz"; \
    curl -fL --retry 3 \
        -o "${novnc_archive}" \
        "https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.tar.gz"; \
    echo "${NOVNC_SHA256}  ${novnc_archive}" | sha256sum -c -; \
    mkdir -p /usr/share/novnc; \
    tar -xzf "${novnc_archive}" --strip-components=1 -C /usr/share/novnc; \
    ln -s vnc.html /usr/share/novnc/index.html; \
    rm -f "${novnc_archive}"

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

ENV DISPLAY=:1 LIBGL_ALWAYS_SOFTWARE=1 QT_STYLE_OVERRIDE=kvantum

# 仅对外暴露 noVNC Web 端口；TurboVNC 默认只在容器回环地址上监听。
EXPOSE 22 6080

ENTRYPOINT ["/entrypoint.sh"]
