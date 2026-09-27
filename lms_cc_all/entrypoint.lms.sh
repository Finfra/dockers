#!/bin/bash
# LMS 백엔드 컨테이너 PID 1 — llmster headless 데몬 구동 (GUI 없음)
#   시퀀스:
#     1) lms daemon up                         (llmster 데몬 기동)
#     2) lms server start --bind 0.0.0.0        (OpenAI /v1 서버, 컨테이너 외부 접근 허용)
#     3) /v1/models 헬스 폴링 (최대 LMS_HEALTH_TRIES 회)
#     4) lms get -y / lms load ${LMS_MODEL}     (없으면 다운로드 후 로드. 실패해도 컨테이너 유지)
#     5) exec lms log stream                    (PID1 인계, SIGTERM 전파)
set -e

LMS_PORT="${LMS_PORT:-1234}"
LMS_HEALTH_TRIES="${LMS_HEALTH_TRIES:-30}"
export PATH="$HOME/.lmstudio/bin:$PATH"

# 1) llmster 데몬 기동 + 준비 대기 (재기동 시 binary 경합/세그폴트 방지)
echo "[lms] starting llmster daemon ..."
lms daemon up || true
for i in $(seq 1 15); do
  lms daemon status >/dev/null 2>&1 && break
  echo "[lms] waiting for daemon ready (${i}/15)"
  sleep 1
done
sleep 1   # 데몬 안정화 — 직후 server start 의 'Text file busy' 회피

# 2) OpenAI 호환 서버 (0.0.0.0 바인딩 → claude 컨테이너에서 접근 가능)
#    'Text file busy' 등 일시 오류 시 짧게 재시도
echo "[lms] starting OpenAI server on 0.0.0.0:${LMS_PORT} ..."
for i in $(seq 1 5); do
  if lms server start --port "${LMS_PORT}" --bind 0.0.0.0; then
    break
  fi
  echo "[lms] server start retry (${i}/5)"
  sleep 2
done

# 3) /v1/models 헬스 폴링 (모델 로드 전에도 200 응답)
echo "[lms] waiting for /v1/models ..."
TRIES=0
until curl -fsS "http://127.0.0.1:${LMS_PORT}/v1/models" >/dev/null 2>&1; do
  TRIES=$((TRIES+1))
  if [ "$TRIES" -ge "$LMS_HEALTH_TRIES" ]; then
    echo "[lms] ERROR: server not ready after $((LMS_HEALTH_TRIES*2))s" >&2
    exit 1
  fi
  echo "[lms] server unavailable - sleeping (${TRIES}/${LMS_HEALTH_TRIES})"
  sleep 2
done
echo "[lms] server is up"

# 3.5) GPU(CUDA) 런타임 자동 선택 — llmster 는 CUDA 백엔드를 설치해도 기본 SELECTED 가
#      CPU(avx2) 인 경우가 있어, --gpu max 여도 CPU 로 추론 → 대형 모델(예: 31B)이 극도로
#      느려 응답 타임아웃(504). LMS_GPU!=off 이고 GPU 가 보이면 CUDA 런타임을 선택한다.
#      (검증: nvidia-smi 로 VRAM 사용 확인. CUDA 미설치면 경고 후 CPU 로 계속.)
if [ "${LMS_GPU:-max}" != "off" ]; then
  if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
    CUDA_ENGINE="$(lms runtime ls 2>/dev/null | grep -iE 'nvidia-cuda' | awk '{print $1}' | head -1)"
    if [ -n "$CUDA_ENGINE" ]; then
      echo "[lms] selecting GPU runtime: ${CUDA_ENGINE}"
      lms runtime select "${CUDA_ENGINE}" || echo "[lms] WARNING: 'lms runtime select' 실패 (계속 진행)"
    else
      echo "[lms] WARNING: CUDA 런타임 미설치 — CPU(avx2)로 동작, 대형 모델 매우 느림"
    fi
  else
    echo "[lms] note: GPU 미감지 — CPU 로 동작(LMS_GPU=${LMS_GPU:-max})"
  fi
fi

# 4) 모델 다운로드(없으면) + 로드 — 실패해도 컨테이너 유지 (docker exec 로 수동 가능)
#    LMS_CONTEXT_LENGTH: 컨텍스트 토큰 상한. Claude Code 는 시스템+도구 페이로드가 크므로
#                        에이전트 용도면 32768 이상 권장 (기본 8192 로는 부족).
#    LMS_GPU: GPU offload 비율 ("max"/"off"/0~1). 기본 max.
if [ -n "${LMS_MODEL:-}" ]; then
  LOAD_OPTS="--yes"
  [ -n "${LMS_CONTEXT_LENGTH:-}" ] && LOAD_OPTS="$LOAD_OPTS --context-length ${LMS_CONTEXT_LENGTH}"
  [ -n "${LMS_GPU:-}" ] && LOAD_OPTS="$LOAD_OPTS --gpu ${LMS_GPU}"
  # LMS_PARALLEL: 동시 예측 슬롯 수. llmster 는 컨텍스트를 슬롯 수로 "분할"하므로
  #   기본값(4)이면 슬롯당 ctx/4 (32k→8k). Claude Code 시스템 프롬프트(~16k)가 슬롯을
  #   초과해 500 (n_keep >= n_ctx) 발생. Claude Code 용도면 1 필수.
  [ -n "${LMS_PARALLEL:-}" ] && LOAD_OPTS="$LOAD_OPTS --parallel ${LMS_PARALLEL}"
  echo "[lms] ensuring model present: ${LMS_MODEL}"
  lms get -y "${LMS_MODEL}" || echo "[lms] WARNING: 'lms get' failed (이미 보유했거나 식별자 확인 필요)"
  echo "[lms] loading model: ${LMS_MODEL} (opts: ${LOAD_OPTS})"
  lms load "${LMS_MODEL}" ${LOAD_OPTS} || echo "[lms] WARNING: model load failed - container stays up for manual 'lms load'"
else
  echo "[lms] WARNING: LMS_MODEL empty - skipping load (use 'docker exec ... lms load <model>')"
fi

# 5) 로그 스트림으로 PID1 인계 (SIGTERM 전파, 컨테이너 foreground 유지)
echo "[lms] handing off to 'lms log stream' (PID1)"
exec lms log stream
