#!/bin/bash
# compose 기동 래퍼. 표준: _doc_arch/patterns/docker-compose/
# SSL 인증서가 없으면 generate-ssl.sh 로 선생성 후 기동.
set -e
cd "$(dirname "$0")"

if [ ! -f ~/.ssh/ssl/server-cert.pem ] || [ ! -f ~/.ssh/ssl/server-key.pem ]; then
    echo "🔐 SSL 인증서 없음 → generate-ssl.sh 실행"
    ./generate-ssl.sh
fi

echo "🚀 docker compose up"
docker compose up -d
docker compose ps
echo "테스트: curl -k https://localhost | 정리: ./clear.sh"
