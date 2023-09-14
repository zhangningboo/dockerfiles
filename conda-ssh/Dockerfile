# 基础镜像
FROM continuumio/miniconda3:latest

# 安装SSH服务器
RUN apt-get update && apt-get install -y openssh-server ca-certificates vim curl net-tools iproute2 iputils-ping zsh

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 设置SSH登录密码
RUN echo 'root:miniconda3' | chpasswd
RUN echo 'Port 22\nPermitRootLogin yes\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

# 声明容器会监听的端口
EXPOSE 22

# 启动容器时运行SSH服务
ENTRYPOINT service ssh start && /bin/zsh