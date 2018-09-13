# It is based on https://www.santoshsrinivas.com/installing-apache-spark-on-ubuntu-16-04/

# Base upgrade
apt-get update && apt-get install -y --no-install-recommends \
                                     --upgrade               \
        build-essential                                      \
        curl                                                 \
        libfreetype6-dev                                     \
        libpng12-dev                                         \
        libzmq3-dev                                          \
        pkg-config                                           \
        python                                               \
        python-pip                                           \
        python-dev                                           \
        virtualenv                                           \
        virtualenvwrapper                                    \
        rsync                                                \
        software-properties-common                           \
        unzip                                                \
        links                                                \
        net-tools                                            \
        vim                                                  \
        apt-transport-https                                  \
        sudo                                                 \
        &&                                                   \
    apt-get clean &&                                         \
    rm -rf /var/lib/apt/lists/*
pip install -U setuptools
pip install --upgrade pip && pip --no-cache-dir install     \
        Pillow                                              \
        h5py                                                \
        ipykernel                                           \
        jupyter                                             \
        matplotlib                                          \
        numpy                                               \
        pandas                                              \
        scipy                                               \
        sklearn                                             \
        &&                                                  \
python -m ipykernel.kernelspec

# Spark install

## Scala install
echo "deb https://dl.bintray.com/sbt/debian /" >> /etc/apt/sources.list.d/sbt.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
apt-get -y update
apt-get -y install sbt
apt-get -y install scala


# ## Java install
# apt-add-repository -y ppa:webupd8team/java
# apt-get update -y
apt-get install -y default-jre
apt-get install -y default-jdk
#apt-get install -y --no-install-recommends java-common oracle-java8-installer

## Uncompress
tar xzvf /_prgs/spark-2.2.0-bin-hadoop2.7.tgz
mv spark-2.2.0-bin-hadoop2.7/ spark
mv spark/ /usr/lib/
cp /usr/lib/spark/conf/spark-env.sh.template /usr/lib/spark/conf/spark-env.sh
echo "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/" >>  /usr/lib/spark/conf/spark-env.sh
echo "SPARK_WORKER_MEMORY=16g" >>  /usr/lib/spark/conf/spark-env.sh

x=$(cat /etc/sysctl.conf|grep ^net.ipv6.conf)
if [  ${#x} -eq 0 ]; then
    echo "net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
fi

x=$(cat /etc/bash.bashrc|grep SPARK_HOME)
if [  ${#x} -eq 0 ]; then
    echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
export SBT_HOME=/usr/share/sbt/bin/sbt-launch.jar
export SPARK_HOME=/usr/lib/spark
export PATH=\$PATH:\$JAVA_HOME/bin
export PATH=\$PATH:\$SBT_HOME/bin:\$SPARK_HOME/bin:\$SPARK_HOME/sbin">>/etc/bash.bashrc
fi



#
