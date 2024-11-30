#!/bin/bash
# System Variable Setting
export LC_ALL=C.UTF-8
export DEBIAN_FRONTEND=noninteractive

echo "export LC_ALL=C.UTF-8">>/etc/bash.bashrc
echo "export DEBIAN_FRONTEND=noninteractive">>/etc/bash.bashrc

apt-get update && \
    apt-get install -y curl wget unzip zip software-properties-common 

# # 필수 패키지 업데이트 및 설치
# RUN apt-get install -y openjdk-8-jdk curl wget unzip zip && \
#     apt-get clean

# java 17
add-apt-repository ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    apt-get clean
# # java 21
# add-apt-repository ppa:openjdk-r/ppa && \
#     apt-get update && \
#     apt-get install -y openjdk-21-jdk && \
#     apt-get clean