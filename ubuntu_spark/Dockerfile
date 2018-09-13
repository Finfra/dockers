FROM ubuntu
MAINTAINER The finfraTeam Project <nowage@gmail.com>




# For Spark
RUN mkdir /_prgs/
COPY ./_prgs/* /_prgs/

COPY ./install.sh /
RUN chmod 755 /install.sh
RUN bash /install.sh

EXPOSE 8081
EXPOSE 8080
EXPOSE 7077


# For Default
WORKDIR "/"


COPY ./start.sh /
RUN chmod 755 /start.sh
CMD /start.sh
