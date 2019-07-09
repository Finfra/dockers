#!/bin/bash
mkdir /home/$USER
useradd -d /home/$USER $USER 
chown $USER:$USER /home/$USER
echo -e "$PASSWD\n$PASSWD" | passwd $USER
echo  $USER password: $PASSWD
/bin/bash

