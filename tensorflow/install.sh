#!/bin/bash
apt-get update
apt-get -y install python3-pip
pip3 install --upgrade pip3
pip3 install tensorflow
pip3 install ipykernel
python3 -m ipykernel install --user --name=Python3
pip3 install jupyter
rm -rf /usr/bin/python
ln -s /usr/bin/python3 /usr/bin/python