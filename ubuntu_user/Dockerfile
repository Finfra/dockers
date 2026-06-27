FROM ubuntu
MAINTAINER The NamjungGu <nowage@gmail.com>
COPY ./start.sh /
RUN chmod 755 /start.sh
RUN apt update -y
RUN DEBIAN_FRONTEND=noninteractive apt install -y python3 python3-pip
RUN ln -sf /usr/bin/python3 /usr/bin/python
# ENTRYPOINT ["/xx/sshd","sshd"]
CMD /start.sh
