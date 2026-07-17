#!/bin/bash
# compose 정리 래퍼
set -e
cd "$(dirname "$0")"
echo "🧹 컨테이너 정리 (cpu/gpu/code compose 모두)"
docker compose -f docker-compose.yml -f docker-compose.gpu.yml -f docker-compose.code.yml down --remove-orphans 2>/dev/null || \
docker compose -f docker-compose.yml down --remove-orphans 2>/dev/null || true

if [ "$1" = "--volumes" ]; then
  echo "🗑️  볼륨(claude-home, ollama-models)까지 삭제합니다."
  docker compose -f docker-compose.yml down --volumes 2>/dev/null || true
fi
echo "✅ 정리 완료 (--volumes 옵션 미사용 시 모델·홈 볼륨은 보존)"
