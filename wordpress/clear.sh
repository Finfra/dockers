#!/bin/bash
# compose 정리 래퍼. 표준: _doc_arch/patterns/docker-compose/
set -e
cd "$(dirname "$0")"
echo "🧹 컨테이너·볼륨(db_data·wordpress_data) 정리"
docker compose down --volumes 2>/dev/null || true
echo "✅ 정리 완료"
