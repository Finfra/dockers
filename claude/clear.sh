#!/bin/bash
# compose 정리 래퍼. 표준: _doc_arch/patterns/docker-compose/
set -e
cd "$(dirname "$0")"
echo "🧹 컨테이너·볼륨 정리"
docker compose --env-file .env down --volumes 2>/dev/null || docker compose down --volumes 2>/dev/null || true
echo "✅ 정리 완료 (df/ 소스는 보존)"
