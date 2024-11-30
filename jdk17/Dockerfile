FROM ubuntu:24.04
RUN apt-get update && \
    apt-get install -y curl wget unzip zip software-properties-common 
# # 필수 패키지 업데이트 및 설치
# RUN apt-get install -y openjdk-8-jdk curl wget unzip zip && \
#     apt-get clean

COPY ./install.sh /
RUN chmod 755 /install.sh
RUN /install.sh