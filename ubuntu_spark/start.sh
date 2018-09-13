#!/bin/bash

# User Create
useradd  $USER
echo "$USER:$PASSWD"|chpasswd
echo  $USER password: $PASSWD

bash
