FROM ubuntu
RUN apt update -y
RUN apt install -y nginx
COPY ./start.sh /
RUN chmod 755 /start.sh
CMD /start.sh
