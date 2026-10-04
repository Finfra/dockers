#!/bin/bash
# vllm_qwen38 동작 점검: health → models → chat completion
cd "$(dirname "$0")"
[ -f .env ] && { set -a; . ./.env; set +a; }
BASE="http://localhost:${VLLM_PORT:-8000}"
MODEL="${SERVED_MODEL_NAME:-qwen3.8-27b}"

echo "== health";  curl -sf "$BASE/health" && echo "OK" || { echo "FAIL (아직 로딩 중일 수 있음)"; exit 1; }
echo "== models";  curl -s "$BASE/v1/models"; echo
echo "== chat"
curl -s "$BASE/v1/chat/completions" -H "Content-Type: application/json" -d "{
  \"model\": \"$MODEL\",
  \"messages\": [{\"role\": \"user\", \"content\": \"한 문장으로 자기소개해줘.\"}],
  \"max_tokens\": 256
}"
echo
echo "== df 공유 볼륨"; docker exec "${VLLM_CONTAINER_NAME:-vllm-qwen38}" ls -la /df
