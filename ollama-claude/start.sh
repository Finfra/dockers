#!/bin/bash
# ollama-claude 시작 스크립트 (GPU 자동 감지 + 코드 마운트 override)
set -e
cd "$(dirname "$0")"

# .env 없으면 sample 로 생성
if [ ! -f .env ]; then
  echo "📋 .env 가 없어 .env.sample 로 생성합니다. 필요 시 OLLAMA_MODEL 등 수정 후 재실행하세요."
  cp .env.sample .env
fi

# .env 로드 (MOUNT_CODE_DIR 판별용)
set -a; . ./.env; set +a

# compose 파일 조합
FILES=(-f docker-compose.yml)

# GPU 감지
if command -v nvidia-smi &> /dev/null; then
  echo "🟢 NVIDIA GPU 감지 — GPU 모드로 실행합니다."
  FILES+=(-f docker-compose.gpu.yml)
else
  echo "⚪ NVIDIA GPU 미감지 — CPU 모드로 실행합니다."
fi

# 호스트 코드 폴더 마운트 (선택)
if [ -n "${MOUNT_CODE_DIR}" ]; then
  echo "📂 코드 폴더 마운트: ${MOUNT_CODE_DIR} → /home/ubuntu/code"
  FILES+=(-f docker-compose.code.yml)
fi

docker compose "${FILES[@]}" up -d --build

echo ""
echo "✅ 시작 완료. 모델(${OLLAMA_MODEL}) pull 은 백그라운드로 진행될 수 있습니다."
echo ""
echo "사용법:"
echo "  - Claude 컨테이너 접속: docker exec -it ${CLAUDE_CONTAINER_NAME:-claude-code} bash"
echo "  - Claude Code 실행:     cc   (= claude --dangerously-skip-permissions)"
echo "  - Ollama API:           http://localhost:${OLLAMA_PORT:-11436}"
echo "  - 환경 테스트:          ./test-setup.sh"
