#!/bin/bash
# vllm_qwen38 정리 (HF 캐시·df 는 호스트 bind 라 보존됨)
set -e
cd "$(dirname "$0")"
docker compose down --remove-orphans
echo "✅ 정리 완료 (모델 캐시: HF_CACHE_DIR, 공유 폴더: DF_DIR 는 보존)"
