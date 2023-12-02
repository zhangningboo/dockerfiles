FROM ubuntu:bionic-20230530
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
    && echo "set nu" >> ~/.vimrc\
    && useradd -m ubuntu -s /bin/bash \
    && adduser ubuntu sudo \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers
# 安装ZSH
RUN apt update
RUN apt install -y net-tools openssh-server build-essential vim curl git zsh lsb-release locales bash-completion
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \  
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && sed -i "s/robbyrussell/ys/" ~/.zshrc \
    && sed -i "s/plugins=(git.*)$/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/" ~/.zshrc \
    && usermod -s /bin/zsh ubuntu
# 更新python
RUN apt install -y python-pip \
    && python -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip \
    && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
    && pip install rosdepc opencv-python==4.1.2.30
# 安装ROS
RUN apt install -q -y --no-install-recommends dirmngr gnupg2
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO melodic
RUN mkdir -p /etc/apt/sources.list.d/
ADD ros-latest.list /etc/apt/sources.list.d/
RUN apt-key adv --keyserver "hkp://keyserver.ubuntu.com:80" --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt update -q \
    && apt install -y ros-melodic-desktop-full python-rosdep \
    && apt install -y python-rosinstall python-rosinstall-generator python-wstool build-essential python-catkin-tools python3-vcstool \
    && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
# 设置时区
RUN echo "TZ='Asia/Shanghai'; export TZ" >> ~/.profile
# RUN apt install -y ros-melodic-ros
# RUN apt install -y ros-melodic-ros-core
# RUN apt install -y ros-melodic-ros-base
# RUN apt install -y ros-melodic-rosbash
# RUN apt install -y ros-melodic-roslib
# RUN apt install -y ros-melodic-rospack
# RUN apt install -y ros-melodic-mk
# RUN apt update \
#     && apt install -y ros-melodic-desktop-full \
#     && apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
RUN sudo usermod -s /bin/zsh ubuntu \
    && sudo rosdepc init  \
    && rosdepc update \
    && echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc && source ~/.bashrc \
    && echo "source /opt/ros/melodic/setup.bash" >> ~/.zshrc && source ~/.zshrc \
    && sudo apt install -y ros-melodic-rosparam-shortcuts \
    && cd ~ && mkdir workspace && cd ~/workspace && git clone https://github.com/gflags/gflags.git \
    && cd gflags && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=ON - DGFLAGS_ NAMESPACE=gflags .. \
    && make -j4 && sudo make install \
    && sudo apt install -y ros-melodic-ros-control ros-melodic-ros-controllers \
    && mkdir -p ~/workspace/catkin_ws/src && cd ~/workspace/catkin_ws && catkin_make \
    && source ~/workspace/catkin_ws/devel/setup.bash
# 安装Moveit
RUN sudo apt install -y python-catkin-tools clang-format-3.9 \
    && sudo apt install -y ros-melodic-moveit \
                      ros-melodic-joint-state-publisher-gui \
                      ros-melodic-moveit-resources \
                      ros-melodic-moveit-visual-tools \
                      ros-melodic-code-coverage \
                      ros-melodic-franka-description \
                      ros-melodic-joy \
                      ros-melodic-canopen-motor-node \
                      ros-melodic-panda-moveit-config \
                      ros-melodic-ecl* \
                      ros-melodic-serial* \
                      ros-melodic-joint-state* \
    && mkdir -p ~/workspace/moveit_ws/src && cd ~/workspace/moveit_ws/src \
    && git clone https://github.com/ros-planning/moveit_tutorials.git -b melodic-devel \
    && sudo rosdep fix-permissions && rosdep install -y --from-paths . --ignore-src --rosdistro melodic \
    && cd ~/workspace/moveit_ws && catkin_make \
    && sudo apt install -y ros-melodic-moveit ros-melodic-moveit-pr2
    # && roslaunch moveit_setup_assistant setup_assistant.launch
# 清除apt缓存
RUN sudo apt autoremove \
    && sudo apt clean -y \
    && sudo rm -rf /var/lib/apt/lists/*
# 设置SSH登录密码
RUN echo 'ubuntu:ubuntu' | chpasswd
RUN echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config
# 声明容器会监听的端口
EXPOSE 22
# 启动容器时运行SSH服务
ENTRYPOINT service ssh start && /bin/zsh