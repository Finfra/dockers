#!/bin/bash
# compose(중첩형) 정리 래퍼. 표준: _doc_arch/patterns/docker-compose/
set -e
cd "$(dirname "$0")/docker"
echo "🧹 컨테이너·볼륨 정리"
docker compose down --volumes 2>/dev/null || true
echo "✅ 정리 완료 (root/ 마운트는 보존)"
