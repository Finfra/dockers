#!/bin/bash
# compose 기동 래퍼. 표준: _doc_arch/patterns/docker-compose/
set -e
cd "$(dirname "$0")"

[ -f .env ] || { echo "📝 .env 생성(.env.sample 기반) — ANTHROPIC_API_KEY 입력 필요"; cp .env.sample .env; }
mkdir -p df

echo "🚀 docker compose up --build"
docker compose --env-file .env up -d --build
docker compose ps
echo "접속: docker compose exec claude bash | 정리: ./clear.sh"
