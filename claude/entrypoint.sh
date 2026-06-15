#!/bin/bash
set -e

# 컨테이너는 ubuntu 유저로 기동됨. 마운트된 소스 폴더 소유권만 sudo 로 정렬.
sudo chown ubuntu:ubuntu /home/users/df 2>/dev/null || true

exec "$@"
