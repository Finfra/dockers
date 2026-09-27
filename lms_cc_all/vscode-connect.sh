#!/usr/bin/env bash
# vscode-connect.sh — 호스트의 Claude Code(CLI·VSCode 확장)를 LMS 백엔드에 직결/해제.
#   (4.lms_OneLLM 직결판 — 게이트웨이 없음, LMS /v1 직결. 원본: 6.lms_MultiLLM_run)
#   Windows 클라이언트는 같은 폴더의 vscode-connect.ps1 사용.
#
#   VSCode Claude Code 확장은 CLI 와 동일하게 ~/.claude/settings.json 을 읽는다.
#   이 스크립트는 그 파일에 아래를 "병합"(기존 키 보존)한다:
#     .env.ANTHROPIC_BASE_URL  = http://<LMS_HOST>:<LMS_PORT>
#     .env.ANTHROPIC_AUTH_TOKEN = lms
#     .model                    = <LMS_MODEL>
#
#   사용:
#     ./vscode-connect.sh on        # 연결 (기본)
#     ./vscode-connect.sh off       # 해제 (우리가 넣은 키만 제거 → Anthropic 복귀)
#     ./vscode-connect.sh status    # 현재 상태
#
#   환경변수 오버라이드:
#     LMS_HOST=192.168.0.4 ./vscode-connect.sh on   # 원격 접속(다른 머신) 시 LMS 호스트 IP
#     CLAUDE_SETTINGS=/경로/settings.json           # 대상 파일 변경(예: 워크스페이스 .claude/settings.local.json)
#
#   전제: docker-compose.yml 이 LMS 포트를 호스트에 publish (.env 의 LMS_BIND_HOST —
#         다른 머신에서 접속하려면 0.0.0.0 필요).
#   ⚠️ 전역 설정을 바꾸므로 호스트의 모든 Claude Code(CLI+확장)가 로컬 LMS 로 향한다.
#      실제 Anthropic 로 되돌리려면 'off'.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION="${1:-on}"

# .env 에서 파라미터 로드
[ -f "$SCRIPT_DIR/.env" ] && set -a && . "$SCRIPT_DIR/.env" && set +a
: "${LMS_PORT:=1234}"
: "${LMS_MODEL:=}"
: "${LMS_HOST:=127.0.0.1}"
: "${CLAUDE_SETTINGS:=$HOME/.claude/settings.json}"
: "${API_TIMEOUT_MS:=600000}"   # 로컬 추론이 느려 첫 응답 지연 → 넉넉한 타임아웃(기본 10분)

BASE_URL="http://${LMS_HOST}:${LMS_PORT}"

command -v jq >/dev/null || { echo "[!] jq 필요 (apt-get install -y jq)"; exit 1; }
mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
[ -f "$CLAUDE_SETTINGS" ] || echo '{}' > "$CLAUDE_SETTINGS"

case "$ACTION" in
  on)
    # LMS 응답 확인 (경고만)
    if curl -fsS "${BASE_URL}/v1/models" >/dev/null 2>&1; then
      echo "[+] LMS 응답 OK: ${BASE_URL}/v1/models"
    else
      echo "[!] LMS 무응답(${BASE_URL}). 먼저 'docker compose up -d' 기동 + LMS_BIND_HOST 확인. (계속 진행)"
    fi
    [ -n "$LMS_MODEL" ] || { echo "[!] .env 의 LMS_MODEL 이 비어있음"; exit 1; }

    # 최초 1회 백업
    BAK="${CLAUDE_SETTINGS}.bak"
    [ -f "$BAK" ] || { cp "$CLAUDE_SETTINGS" "$BAK"; echo "[+] 백업: $BAK"; }

    tmp="$(mktemp)"
    jq --arg url "$BASE_URL" --arg model "$LMS_MODEL" --arg timeout "$API_TIMEOUT_MS" '
      .env = (.env // {})
      | .env.ANTHROPIC_BASE_URL = $url
      | .env.ANTHROPIC_AUTH_TOKEN = "lms"
      | .env.API_TIMEOUT_MS = $timeout
      | .env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
      | .model = $model
    ' "$CLAUDE_SETTINGS" > "$tmp" && mv "$tmp" "$CLAUDE_SETTINGS"

    echo "[+] 연결 설정 완료 → $CLAUDE_SETTINGS"
    echo "      ANTHROPIC_BASE_URL = $BASE_URL"
    echo "      model              = $LMS_MODEL"
    echo "      API_TIMEOUT_MS     = $API_TIMEOUT_MS  (느린 로컬 추론 대비)"
    echo "      CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1  (비-Anthropic 엔드포인트)"
    echo
    echo "  다음: VSCode 에서 명령팔레트 → 'Developer: Reload Window' (또는 확장 재시작)"
    ;;

  off)
    tmp="$(mktemp)"
    jq --arg model "$LMS_MODEL" '
      if .env then .env |= del(.ANTHROPIC_BASE_URL, .ANTHROPIC_AUTH_TOKEN, .API_TIMEOUT_MS, .CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC) else . end
      | if (.env == {}) then del(.env) else . end
      | if (.model == $model) then del(.model) else . end
    ' "$CLAUDE_SETTINGS" > "$tmp" && mv "$tmp" "$CLAUDE_SETTINGS"
    echo "[+] 연결 해제(우리가 넣은 키 제거) → $CLAUDE_SETTINGS"
    echo "      (전체 복원이 필요하면: cp ${CLAUDE_SETTINGS}.bak ${CLAUDE_SETTINGS})"
    echo "  다음: VSCode 'Developer: Reload Window'"
    ;;

  status)
    echo "대상: $CLAUDE_SETTINGS"
    jq '{model, env: (.env // {} | {ANTHROPIC_BASE_URL, ANTHROPIC_AUTH_TOKEN, API_TIMEOUT_MS, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC})}' "$CLAUDE_SETTINGS"
    echo "LMS(${BASE_URL}) 응답:"
    curl -fsS "${BASE_URL}/v1/models" 2>/dev/null | jq -r '.data[].id' | sed 's/^/  - /' || echo "  (무응답)"
    ;;

  *) echo "usage: $0 {on|off|status}"; exit 2 ;;
esac
