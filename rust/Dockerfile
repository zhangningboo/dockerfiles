# 基础镜像
FROM rust:latest

# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive

# 切换源
ADD debian.sources /etc/apt/sources.list.d/
# 安装服务
RUN apt-get update && apt-get install -y openssh-server ca-certificates vim curl wget net-tools iproute2 iputils-ping zsh git ntpdate libopenmpi-dev

# oh my zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#设置时区
RUN echo "TZ='Asia/Shanghai'; export TZ" >> ~/.profile

# 设置SSH登录密码
RUN echo 'root:rust1234' | chpasswd
RUN echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

# 声明容器会监听的端口
EXPOSE 22

# 启动容器时运行SSH服务
ENTRYPOINT service ssh start && /bin/zsh