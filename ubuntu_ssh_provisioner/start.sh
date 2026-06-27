#!/bin/bash
# compose(중첩형) 기동 래퍼. 표준: _doc_arch/patterns/docker-compose/ "중첩 변형"
set -e
cd "$(dirname "$0")/docker"
echo "🚀 docker compose up --build (./docker)"
docker compose up -d --build
docker compose ps
echo "접속 예: docker compose exec <service> bash | 정리: ../clear.sh"
