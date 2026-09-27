#!/bin/bash
# Claude Code 클라이언트 컨테이너 PID 1 — 이미 USER=ubuntu (Dockerfile USER ubuntu)
#   - 내부 네트워크의 LMS 백엔드(headless lms CLI, OpenAI /v1)에 직결
#   - 변환 게이트웨이 없음: ANTHROPIC_BASE_URL 이 LMS :PORT 를 직접 가리킴
#   - LMS_HOST: LMS 컨테이너명 (기본 lms), LMS_PORT: LMS 포트 (기본 1234)
set -e

LMS_HOST="${LMS_HOST:-lms}"
LMS_PORT="${LMS_PORT:-1234}"

# claude settings.json 생성 (LMS OpenAI 엔드포인트 직결 반영)
mkdir -p "$HOME/.claude"
cat > "$HOME/.claude/settings.json" <<JSON
{
  "model": "${ANTHROPIC_MODEL:-${LMS_MODEL:-}}",
  "env": {
    "ANTHROPIC_BASE_URL": "http://${LMS_HOST}:${LMS_PORT}",
    "ANTHROPIC_AUTH_TOKEN": "lms"
  }
}
JSON

# LMS 백엔드 연결 확인 (해석 가능하면 /v1/models 대기, 아니면 경고 후 진행)
if getent hosts "$LMS_HOST" >/dev/null 2>&1; then
  echo "[entrypoint] waiting for LMS at ${LMS_HOST}:${LMS_PORT} ..."
  TRIES=0
  until curl -fsS "http://${LMS_HOST}:${LMS_PORT}/v1/models" >/dev/null 2>&1; do
    TRIES=$((TRIES+1))
    if [ "$TRIES" -ge 60 ]; then
      echo "[entrypoint] WARNING: LMS unreachable after 120s — continuing anyway"
      break
    fi
    echo "[entrypoint] LMS unavailable - sleeping (${TRIES}/60)"
    sleep 2
  done
  if curl -fsS "http://${LMS_HOST}:${LMS_PORT}/v1/models" >/dev/null 2>&1; then
    echo "[entrypoint] LMS is up - starting Claude Code environment"
  fi
else
  echo "[entrypoint] WARNING: host '${LMS_HOST}' not resolvable - check service name / LMS_HOST"
fi

exec "$@"
