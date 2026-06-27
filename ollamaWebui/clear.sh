#!/bin/bash
# compose 정리 래퍼. 표준: _doc_arch/patterns/docker-compose/
set -e
cd "$(dirname "$0")"
echo "🧹 컨테이너·볼륨 정리 (cpu/gpu compose 모두)"
docker compose -f docker-compose.yml down --remove-orphans --volumes 2>/dev/null || true
docker compose -f docker-compose.gpu.yml down --remove-orphans --volumes 2>/dev/null || true
docker network rm onet 2>/dev/null || true
echo "✅ 정리 완료 (~/.ollama 모델·./webui 데이터는 보존)"
