# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/pyspark-notebook

MAINTAINER Jupyter Project <jupyter@googlegroups.com>

USER root

# Steve J.South [NamJungGu] <nowage@gmail.com>  ###########################################
#RUN echo $NB_USER:nowage | chpasswd
#RUN echo  $NB_USER password: nowage
RUN chmod 777 /etc/sudoers
RUN echo "$NB_USER ALL=(ALL)   NOPASSWD: ALL">>/etc/sudoers
RUN chmod 440 /etc/sudoers
RUN chown $NB_USER -R /home/$NB_USER/work


#RUN echo "export SPARK_HOME=/usr/local/spark">>/home/$NB_USER/.bashrc
RUN echo "export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin">>/home/$NB_USER/.bashrc
RUN echo "export PYTHONPATH=\$SPARK_HOME/python:\$SPARK_HOME/python/lib/py4j-0.10.7-src.zip">>/home/$NB_USER/.bashrc
RUN echo "export MESOS_NATIVE_LIBRARY=/usr/local/lib/libmesos.so">>/home/$NB_USER/.bashrc
#RUN echo "export SPARK_OPTS='--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info'">>/home/$NB_USER/.bashrc
RUN chown $NB_USER -R /home/$NB_USER/.bashrc
###############################################################################

COPY ./install.sh /
RUN chmod 755 /install.sh
RUN bash /install.sh

USER $NB_USER
