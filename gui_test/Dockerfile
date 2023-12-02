FROM ubuntu:22.04
# 取消交互操作
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y ca-certificates
ADD sources.list /etc/apt/
RUN apt-get update
RUN apt install -y snapd packagekit-gtk3-module libasound2 libdbus-glib-1-2

ADD Firefox-latest-x86_64.tar.bz2 /opt/
