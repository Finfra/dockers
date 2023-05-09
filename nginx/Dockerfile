FROM ubuntu
COPY ./install.sh /
RUN chmod 755 /install.sh
RUN /install.sh
RUN apt install -y vim
CMD [ "nginx", "-g", "daemon off;"]
expose 80
