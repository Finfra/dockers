#!/bin/bash
# ollama-claude 환경 테스트 스크립트
set -e
cd "$(dirname "$0")"

# .env 로드 (컨테이너명·모델 판별용)
[ -f .env ] && { set -a; . ./.env; set +a; }
OLLAMA_NAME=${OLLAMA_CONTAINER_NAME:-ollama-claude}
CLAUDE_NAME=${CLAUDE_CONTAINER_NAME:-claude-code}
MODEL=${OLLAMA_MODEL:-qwen3-coder:30b}

echo "=== ollama-claude 환경 테스트 ==="
echo ""

# 1. 컨테이너 상태
echo "[1/5] 컨테이너 상태 확인..."
docker ps | grep -q "$OLLAMA_NAME" && echo "✅ Ollama($OLLAMA_NAME) 실행 중" || { echo "❌ Ollama 미실행"; exit 1; }
docker ps | grep -q "$CLAUDE_NAME" && echo "✅ Claude($CLAUDE_NAME) 실행 중" || { echo "❌ Claude 미실행"; exit 1; }
echo ""

# 2. Ollama 헬스체크
echo "[2/5] Ollama 헬스체크..."
docker exec "$OLLAMA_NAME" curl -s http://localhost:11434/api/tags > /dev/null 2>&1 \
  && echo "✅ Ollama API 응답 정상" || { echo "❌ Ollama API 응답 없음"; exit 1; }
echo ""

# 3. 모델 확인
echo "[3/5] Ollama 모델 확인..."
docker exec "$OLLAMA_NAME" ollama list | grep -q "${MODEL%%:*}" \
  && echo "✅ $MODEL 모델 설치됨" || echo "⚠️  $MODEL 미설치 (pull 진행 중일 수 있음)"
echo ""

# 4. Claude → Ollama 네트워크
echo "[4/5] Claude → Ollama 네트워크 연결 테스트..."
docker exec "$CLAUDE_NAME" nc -z ollama 11434 \
  && echo "✅ Claude → Ollama 연결 성공" || { echo "❌ 연결 실패"; exit 1; }
echo ""

# 5. settings.json 확인
echo "[5/5] ubuntu 유저 환경 확인..."
docker exec "$CLAUDE_NAME" test -f /home/ubuntu/.claude/settings.json \
  && echo "✅ settings.json 존재" || { echo "❌ settings.json 미존재"; exit 1; }
echo ""

echo "=== 테스트 완료 — 모든 검사 통과 ==="
echo ""
echo "사용법:"
echo "  - ubuntu 유저: docker exec -it $CLAUDE_NAME bash"
echo "  - root 유저:   docker exec -it -u root $CLAUDE_NAME bash"
echo "  - Claude Code: cc"
