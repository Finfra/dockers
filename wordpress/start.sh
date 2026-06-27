#!/bin/bash
# compose 기동 래퍼. 표준: _doc_arch/patterns/docker-compose/
# 주의: 비밀번호가 docker-compose.yml 에 하드코딩됨(테스트 전용). 운영 전 .env 분리 권장.
set -e
cd "$(dirname "$0")"
HEALTH_URL="http://localhost:8000"

echo "🚀 docker compose up"
docker compose up -d
echo "⏱️  헬스체크: $HEALTH_URL"
until curl -s "$HEALTH_URL" > /dev/null; do echo "  대기..."; sleep 5; done
echo "✅ 기동 완료: $HEALTH_URL"
docker compose ps
echo "정리: ./clear.sh"
