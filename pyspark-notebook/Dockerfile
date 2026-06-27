# 공식 jupyter/pyspark-notebook 사용 (Spark·pyspark·OpenJDK 내장).
# 구버전(jupyter/scipy-notebook + 수동 Spark/Mesos, jessie-backports EOL)에서 현대화 — Issue11.
FROM quay.io/jupyter/pyspark-notebook:latest

USER root

# NB_USER 무암호 sudo (기존 동작 보존)
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${NB_USER} && \
    chmod 440 /etc/sudoers.d/${NB_USER}

USER ${NB_USER}

# SPARK_HOME 는 base 이미지가 이미 설정. PATH 보강만.
RUN echo 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' >> /home/${NB_USER}/.bashrc
