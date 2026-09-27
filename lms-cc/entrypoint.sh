#!/bin/bash
# 범용 Claude Code 컨테이너 PID 1 (USER=ubuntu)
#   - ANTHROPIC_BASE_URL 이 지정되면: settings.json 생성 + 백엔드 TCP 대기
#   - 미지정이면: Anthropic 공식 API 모드 (settings.json 생성 안 함, claude 로그인 필요)
set -e

if [ -n "$ANTHROPIC_BASE_URL" ]; then
  # URL 에서 host / port 추출 (기본 포트: http 80)
  hostport="${ANTHROPIC_BASE_URL#*://}"
  hostport="${hostport%%/*}"
  BACKEND_HOST="${hostport%%:*}"
  BACKEND_PORT="${hostport##*:}"
  [ "$BACKEND_PORT" = "$BACKEND_HOST" ] && BACKEND_PORT=80

  # settings.json 생성 (매 기동 시 갱신 — 볼륨에 남은 이전 설정 덮어씀)
  mkdir -p "$HOME/.claude"
  cat > "$HOME/.claude/settings.json" <<JSON
{
  "model": "${ANTHROPIC_MODEL:-}",
  "env": {
    "ANTHROPIC_BASE_URL": "${ANTHROPIC_BASE_URL}",
    "ANTHROPIC_AUTH_TOKEN": "${ANTHROPIC_AUTH_TOKEN:-dummy}"
  }
}
JSON

  # 백엔드 연결 대기 (해석 가능하면 최대 120초 TCP 대기, 아니면 경고 후 진행)
  if getent hosts "$BACKEND_HOST" >/dev/null 2>&1; then
    echo "[entrypoint] waiting for backend at ${BACKEND_HOST}:${BACKEND_PORT} ..."
    TRIES=0
    until (exec 3<>"/dev/tcp/${BACKEND_HOST}/${BACKEND_PORT}") 2>/dev/null; do
      TRIES=$((TRIES+1))
      if [ "$TRIES" -ge 60 ]; then
        echo "[entrypoint] WARNING: backend unreachable after 120s — continuing anyway"
        break
      fi
      echo "[entrypoint] backend unavailable - sleeping (${TRIES}/60)"
      sleep 2
    done
    exec 3>&- 2>/dev/null || true
    echo "[entrypoint] backend check done - starting Claude Code environment"
  else
    echo "[entrypoint] WARNING: host '${BACKEND_HOST}' not resolvable - check ANTHROPIC_BASE_URL"
  fi
else
  echo "[entrypoint] ANTHROPIC_BASE_URL not set - using official Anthropic API (run 'claude' to login)"
fi

exec "$@"
