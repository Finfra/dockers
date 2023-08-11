FROM ubuntu
COPY ./install.sh /
RUN chmod 755 /install.sh
RUN /install.sh
EXPOSE 80
STOPSIGNAL SIGQUIT
CMD [ "nginx", "-g", "daemon off;"]

