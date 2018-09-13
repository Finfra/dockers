# "ported" by Adam Miller <maxamillion@fedoraproject.org> from
#   https://github.com/fedora-cloud/Fedora-Dockerfiles
#
# Originally written for Fedora-Dockerfiles by
#   scollier <scollier@redhat.com>

FROM mysql
MAINTAINER The finfraTeam Project <nowage@gmail.com>


COPY ./install.sh /
RUN chmod 755 /install.sh
RUN bash /install.sh



#COPY ./start.sh /
#RUN chmod 755 /start.sh
# ENTRYPOINT ["/xx/sshd","sshd"]
#CMD /start.sh
