#!/bin/bash
# compose 정리 래퍼. 표준: _doc_arch/patterns/docker-compose/
set -e
cd "$(dirname "$0")"
echo "🧹 컨테이너·볼륨 정리"
docker compose down --remove-orphans --volumes 2>/dev/null || true
echo "🧹 data 비움 (setting 제외 원하면 주석 조정)"
rm -rf data/share/* data/log/* data/contents/* 2>/dev/null || true
echo "✅ 정리 완료 (data/setting 인증정보는 보존)"
