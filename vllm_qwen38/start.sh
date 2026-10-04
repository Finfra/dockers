#!/bin/bash
# vllm_qwen38 시작 스크립트 (vLLM + TurboQuant KV cache)
set -e
cd "$(dirname "$0")"

if [ ! -f .env ]; then
  echo "📋 .env 가 없어 .env.sample 로 생성합니다."
  cp .env.sample .env
fi
set -a; . ./.env; set +a

if ! command -v nvidia-smi &> /dev/null; then
  echo "❌ NVIDIA GPU 미감지 — vLLM 은 GPU 필수입니다." >&2
  exit 1
fi

# 드라이버 버전 점검 (cu129 이미지 기준 575+ 권장) — 미달 시 경고만 출력하고 진행
DRV=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)
if [ "${DRV%%.*}" -lt 575 ]; then
  echo "⚠️  NVIDIA 드라이버 ${DRV} (<575) — compose 의 구형 드라이버 우회(cu129 재빌드 이미지 + NVIDIA_DISABLE_REQUIRE)로 기동합니다." >&2
fi

# 공유 df 폴더·HF 캐시 폴더 보장 (root 소유로 생성되는 것 방지)
mkdir -p "${DF_DIR/#\~/$HOME}" "${HF_CACHE_DIR/#\~/$HOME}" "${VLLM_CACHE_DIR/#\~/$HOME}"

docker compose up -d --build

echo ""
echo "✅ 시작 요청 완료. 모델(${VLLM_MODEL}) 다운로드·로드는 수 분 소요됩니다."
echo "  - KV cache: ${KV_CACHE_DTYPE}"
echo "  - 로그:     docker logs -f ${VLLM_CONTAINER_NAME:-vllm-qwen38}"
echo "  - API:      http://localhost:${VLLM_PORT:-8000}/v1"
echo "  - 테스트:   ./test.sh"
