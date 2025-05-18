FROM ubuntu:22.04

RUN apt-get update && rm -rf /var/lib/apt/lists/*
WORKDIR /root

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd

# root 사용자 비밀번호 설정
RUN mkdir -p /var/run/ssh
RUN echo 'root:password' | chpasswd

# SSH 설정 변경
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# SSH 포트 노출
EXPOSE 22


# installOnEc2.sh 복사 및 실행
COPY installOnEc2.sh /tmp/installOnEc2.sh
RUN chmod +x /tmp/installOnEc2.sh && /tmp/installOnEc2.sh

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

CMD ["/usr/local/bin/startup.sh"]
