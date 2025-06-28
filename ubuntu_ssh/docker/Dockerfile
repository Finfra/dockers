FROM ubuntu:22.04

RUN apt-get update && rm -rf /var/lib/apt/lists/*
WORKDIR /root

# SSH 서버 설치 및 설정
RUN apt-get update && apt-get install -y openssh-server
RUN apt -y install unzip curl jq git wget vim
RUN apt -y install locales
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN mkdir /var/run/sshd

# root 사용자 비밀번호 설정
RUN mkdir -p /var/run/ssh
RUN mkdir -p /root/.ssh
RUN chmod 700 /root/.ssh

RUN echo 'root:password' | chpasswd

# ssh 공개키 복사 및 root authorized_keys 등록
COPY ssh/id_rsa.pub /tmp/id_rsa.pub
RUN mkdir -p /root/.ssh && cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys

# ubuntu 사용자 추가 및 sudo 권한 부여, 패스워드 설정, 비번 없이 sudo 가능하게 설정
RUN apt-get update && apt-get install -y sudo \
    && useradd -m -s /bin/bash ubuntu \
    && echo 'ubuntu:password' | chpasswd \
    && usermod -aG sudo ubuntu \
    && echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# ubuntu authorized_keys 등록 (ubuntu 생성 이후)
RUN mkdir -p /home/ubuntu/.ssh && cat /tmp/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys && chmod 600 /home/ubuntu/.ssh/authorized_keys && chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# SSH 설정 변경
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config

# SSH 포트 노출
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
