FROM osrf/ros:melodic-desktop-full

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
${NVIDIA_VISIBLE_DEVICES:-all}

ENV NVIDIA_DRIVER_CAPABILITIES \
${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN rm -rf /etc/apt/sources.list.d/ros1-snapshots.list \
    && apt update \
    && apt install curl \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros.list > /dev/null \
    && apt update \
    && apt install -y \
    build-essential \
    libgl1-mesa-dev \
    libglew-dev \
    libsdl2-dev \
    libsdl2-image-dev \
    libglm-dev \
    libfreetype6-dev \
    libglfw3-dev \
    libglfw3 \
    libglu1-mesa-dev \
    freeglut3-dev \
    vim
