FROM oraclelinux:9

RUN dnf -y update && dnf clean all
WORKDIR /root

# SSH 서버 설치 및 설정
RUN dnf -y install openssh-server passwd && dnf clean all
RUN mkdir /var/run/sshd

# root 사용자 비밀번호 설정
RUN mkdir -p /var/run/ssh
RUN echo 'root:password' | chpasswd

# SSH 설정 변경
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config || sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config || sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# SSH 포트 노출
EXPOSE 22

RUN ssh-keygen -A

CMD ["/usr/sbin/sshd", "-D"] 