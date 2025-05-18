#!/bin/bash

# Version Setting
TERRAFORM_VERSION="1.12.0"
ANSIBE_VERSION="11.5.0"              # core 2.18.5

# System Variable Setting
export LC_ALL=C.UTF-8
export DEBIAN_FRONTEND=noninteractive

grep -qxF "export LC_ALL=C.UTF-8" /root/.bashrc || echo "export LC_ALL=C.UTF-8" >> /root/.bashrc
grep -qxF "export DEBIAN_FRONTEND=noninteractive" /root/.bashrc || echo "export DEBIAN_FRONTEND=noninteractive" >> /root/.bashrc

# hostname provisioner
# hostname > /etc/hostname

apt -y update
apt -y install unzip curl jq git wget vim

# install pip
add-apt-repository ppa:deadsnakes/ppa -y
apt update
apt install -y python3.11 # python3.11-venv python3.11-dev python3.11-distutils
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11
update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# install awscli
python -m pip install awscli
#python3 -m pip install  awsebcli
complete -C aws_completer aws

# install ansible
pip install netaddr jinja2
pip install ansible==$ANSIBE_VERSION

# for Language Setting
grep -qxF "set input-meta on" /root/.bashrc || cat << EOF >> /root/.bashrc
set input-meta on
set output-meta on
set convert-meta off
EOF

# clean up
apt-get clean

# Terraform Install
[[ ! $(which terraform) ]] \
    && wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
    && rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.*

# # Setting for ssh
# [[ ! $(cat /etc/ssh/ssh_config|grep \^StrictHostKeyChecking) ]] \
#     && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# Setting for Convenient
grep -qxF "export EDITOR=vi" /root/.bashrc || echo "export EDITOR=vi" >> /root/.bashrc
# Terraform Apply alias
cmd='
terraform destroy -auto-approve
terraform init
terraform apply -auto-approve
cat terraform.tfstate|grep public_ip|grep -v associate
'
grep -q "^alias ta=" /root/.bashrc || echo "alias ta=\"echo '$cmd';$cmd\"">>/root/.bashrc

# Terraform Destroy alias
cmd='terraform destroy -auto-approve
'
grep -q "^alias td=" /root/.bashrc || echo "alias td=\"echo '$cmd';$cmd\"">>/root/.bashrc

## Alias for Delete aws Key pair
cmd='aws ec2 delete-key-pair --key-name mykey
'
# Check if alias already exists before adding
grep -q "^alias dk=" /root/.bashrc || echo "alias dk=\"echo '$cmd';$cmd\"" >> /root/.bashrc

# . ~/.bashrc
