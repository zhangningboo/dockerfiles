# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE=registry.cn-hangzhou.aliyuncs.com/zhangningboo/linux_arm64_v8_ubuntu:22.04
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG UBUNTU_MIRROR=mirrors.tuna.tsinghua.edu.cn
ARG ROS2_MIRROR=mirrors.ustc.edu.cn
ARG ROOT_PASSWORD=ubuntu
ARG VIRTUALGL_VERSION=3.1.5
ARG VIRTUALGL_ARM64_SHA256=9ac238e8a18c06d84ef65444a591a7a5bb4c4ce9e8cfdd92f8a2aea35edbb5d7
ARG VIRTUALGL_AMD64_SHA256=df3f7788ce41b182a47c0d298e5cd6d2d63579522cb41825970b7726e825485e

ENV ROS_DISTRO=humble \
    ROS_VERSION=2 \
    ROS_PYTHON_VERSION=3

# 保留 CUDA 基础镜像已有的驱动能力，并补充 GUI 所需的 graphics。
ENV NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# 配置 Ubuntu/ROS 2 软件源。APT 的索引和 deb 包只保留在构建缓存中，
# 后续重建可以复用，但不会进入最终镜像层。
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && sed -Ei \
        -e "s@https?://(archive|security).ubuntu.com/ubuntu@http://${UBUNTU_MIRROR}/ubuntu@g" \
        -e "s@https?://ports.ubuntu.com/ubuntu-ports@http://${UBUNTU_MIRROR}/ubuntu-ports@g" \
        /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
        -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && chmod 0644 /usr/share/keyrings/ros-archive-keyring.gpg \
    && . /etc/os-release \
    && printf 'deb [arch=%s signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://%s/ros2/ubuntu %s main\n' \
        "$(dpkg --print-architecture)" "${ROS2_MIRROR}" "${UBUNTU_CODENAME:-${VERSION_CODENAME}}" \
        > /etc/apt/sources.list.d/ros2.list

# 系统工具、X11/OpenGL 组件与 ROS 放在同一安装层，避免重复 update/install 和无效缓存层。
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        build-essential \
        git \
        git-lfs \
        iputils-ping \
        libasound2 \
        libdbus-glib-1-2 \
        locales \
        net-tools \
        openssh-server \
        python3-colcon-common-extensions \
        python3-pip \
        ros-${ROS_DISTRO}-foxglove-bridge \
        ros-${ROS_DISTRO}-image-transport \
        ros-${ROS_DISTRO}-ros-base \
        ros-${ROS_DISTRO}-rviz2 \
        ros-${ROS_DISTRO}-tf2-ros \
        ros-${ROS_DISTRO}-urdf-launch \
        ros-${ROS_DISTRO}-vision-msgs \
        supervisor \
        vim \
        wget \
        xauth \
        xvfb \
        zsh \
    && vgl_arch="$(dpkg --print-architecture)" \
    && case "${vgl_arch}" in \
        arm64) vgl_sha="${VIRTUALGL_ARM64_SHA256}" ;; \
        amd64) vgl_sha="${VIRTUALGL_AMD64_SHA256}" ;; \
        *) echo "Unsupported VirtualGL architecture: ${vgl_arch}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL \
        "https://github.com/VirtualGL/virtualgl/releases/download/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_${vgl_arch}.deb" \
        -o /tmp/virtualgl.deb \
    && echo "${vgl_sha}  /tmp/virtualgl.deb" | sha256sum -c - \
    && apt-get install -y --no-install-recommends /tmp/virtualgl.deb \
    && rm -f /tmp/virtualgl.deb \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && echo "root:${ROOT_PASSWORD}" | chpasswd \
    && install -d -m 0755 /run/sshd \
    && printf '%s\n' \
        'Port 22' \
        'PermitRootLogin yes' \
        'PasswordAuthentication yes' \
        'X11Forwarding yes' \
        'X11UseLocalhost yes' \
        'X11DisplayOffset 10' \
        > /etc/ssh/sshd_config.d/00-container.conf \
    && printf '%s\n' '. /opt/ros/humble/setup.sh' > /etc/profile.d/ros2.sh

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Shanghai \
    QT_X11_NO_MITSHM=1 \
    XDG_RUNTIME_DIR=/tmp/runtime-root

WORKDIR /root
COPY .gitconfig /root/.gitconfig

# 浅克隆并移除仓库元数据，减少网络传输和最终镜像体积。
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
        /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
        /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc \
    && sed -i 's/^ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/' /root/.zshrc \
    && sed -i 's/^plugins=(git)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' /root/.zshrc \
    && printf '%s\n' \
        'source /opt/ros/humble/setup.bash' \
        "alias ros2='ros2-x11'" \
        "alias rviz2='rviz2-x11'" \
        >> /root/.bashrc \
    && printf '%s\n' \
        'setopt nonomatch' \
        'source /opt/ros/humble/setup.zsh' \
        "alias ros2='ros2-x11'" \
        "alias rviz2='rviz2-x11'" \
        >> /root/.zshrc \
    && printf '%s\n' 'set nu' > /root/.vimrc \
    && rm -rf \
        /root/.oh-my-zsh/.git \
        /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions/.git \
        /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/.git

COPY --chmod=0755 entrypoint.sh /entrypoint.sh
COPY --chmod=0755 ros2-x11.sh /usr/local/bin/ros2-x11
COPY --chmod=0755 rviz2-x11.sh /usr/local/bin/rviz2-x11
COPY --chmod=0644 supervisord.conf /etc/supervisor/conf.d/ros2.conf

EXPOSE 22 8765

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/ros2.conf"]
