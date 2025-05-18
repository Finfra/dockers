#!/bin/bash

# config.sh 적용 및 안내 (컨테이너 실행 시점)
if [ -f /root/config.sh ]; then
    grep -qxF "source /root/config.sh" /root/.bashrc || echo "source /root/config.sh" >> /root/.bashrc
else
    echo "[provisioner] /root/config.sh 파일이 없습니다. 예시 파일을 복사해 생성하세요: cp /root/config.sh.example /root/config.sh" >&2
fi

service ssh start

exec /bin/bash
