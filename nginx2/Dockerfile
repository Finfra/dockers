FROM ubuntu
COPY ./install.sh /
RUN chmod 755 /install.sh
RUN /install.sh
CMD [ "nginx", "-g", "daemon off;"]
expose 80
