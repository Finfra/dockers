# 4.lms_OneLLM

LM Studio(**headless `lms` CLI**) 추론 컨테이너 1개 + Claude Code 컨테이너 1개로 구성한 단일-LLM 예제.
claude CLI 가 LMS 의 OpenAI 호환 `/v1` 엔드포인트에 **변환 게이트웨이 없이 직결**되는지 검증하는 단계이며, 다음 단계 `5.lms_MultiLLM`(게이트웨이 + 다중 백엔드)의 청사진이다.

> 설계 SSOT: [`_doc_arch/lms-multi-gateway-design.md`](../../air-gap-claudeCode/_doc_arch/lms-multi-gateway-design.md)
> 전체 예제 비교: 루트 [`README.md`](../../air-gap-claudeCode/README.md)

---

## fg1 전용 설치 (2026-07-16 전환 · 2026-07-17 dockers 저장소로 이전)

원래 air-gap 반입용으로 만들었으나 응답속도가 좋아 **fg1 서버 상시 보조 LLM** 으로 용도 전환.
air-gap 원본은 [`4.1.lms_OneLLM/`](../../air-gap-claudeCode/4.1.lms_OneLLM/) 에 보존 (수정 금지).

* **모델 저장소 호스트 공유**: `.env` 의 `LMS_MODEL_MOUNT=~/.lmstudio/models` — 호스트 LM Studio
  와 같은 디렉토리를 사용해 중복 다운로드 없음. named volume 격리가 필요하면 빈값으로.
* **설치 모델 3종** (16GB GPU·32k ctx·PARALLEL 1, 한 번에 1개 로드 — 2026-07-16 실측):

  | `LMS_MODEL` 키 (lms ls) | 모델 | 파일 | 정속 속도 | `--gpu` | VRAM |
  | :--- | :--- | :--- | :--- | :--- | :--- |
  | `qwen/qwen3-coder-30b` (기본) | Qwen3-Coder-30B-A3B MoE | Q3_K_L 14.6GB | 31~37 tok/s | 0.8 | 13.9GB |
  | `gemma-4-26b-a4b-it` | Gemma 4 26B-A4B MoE (비전 포함) | Q4_K_M 16.8GB | ~14 tok/s | 0.8 | 15.7GB |
  | `devstral-small-2507` | Devstral Small 24B dense | Q4_K_M 14.3GB | ~5 tok/s | 0.75 | 14.5GB |

  세 모델 모두 가중치+32k KV 가 16GB 를 넘어 `LMS_GPU=max` 는 **CUDA OOM** — 부분 offload 필수.
  MoE(qwen·gemma)는 CPU 분할 페널티가 작고, dense(devstral)는 크다.
* **모델 전환**: `.env` 의 `LMS_MODEL`(위 키)·`LMS_GPU` 변경 후 `docker compose restart lms`
  (또는 `docker exec lms bash -lc 'lms unload --all && lms load <키> --gpu 0.8 --context-length 32768 --parallel 1 -y'`).
* **이미지 무변경 원칙**: 기동 시 `--build` 금지 (`lms:latest`/`claude:latest` 는 air-gap 반입본).
  air-gap 반입본 이미지의 내장 entrypoint 문제(lms=`sleep infinity`, claude=gateway 직결판)는
  `docker-compose.yml` 이 폴더의 `entrypoint*.sh` 를 bind mount 로 주입해 해결함.

---

## 토폴로지

```
┌──────────────┐   ANTHROPIC_BASE_URL        ┌────────────────────────────┐
│   claude     │   = http://lms:1234         │   lms (headless lms CLI)   │
│ (Claude Code)│ ──────────────────────────► │  lms server  →  /v1 (OpenAI)│
└──────────────┘   ANTHROPIC_AUTH_TOKEN=lms  └────────────────────────────┘
        └──────── docker network: lms ───────────────┘
        claude 는 lms healthcheck(/v1/models) 통과 후 기동
```

* 컨테이너 2개: `lms`(추론 백엔드) + `claude`(클라이언트). `2.ollama_TwoContainer` 구조 계승 — `lms` 가 `ollama` 자리를 대체.
* **GUI 없음**: LM Studio 데스크톱 앱이 아니라 헤드리스 `lms` CLI 만 구동. 제어는 `lms server`/`lms load`/`lms log stream` 와 `/v1` API.
* **직결**: Anthropic↔OpenAI 변환 프록시가 필요 없음 (prj81 검증).

---

## 파일 구성

| 파일                      | 역할                                                                                                       |
| :------------------------ | :--------------------------------------------------------------------------------------------------------- |
| `Dockerfile.lms`          | headless `lms` CLI 백엔드 이미지                                                                           |
| `entrypoint.lms.sh`       | LMS PID1: `lms daemon up` → `lms server start --bind 0.0.0.0` → `/v1/models` 폴링 → `lms get`/`lms load`(context·GPU) → `exec lms log stream` |
| `Dockerfile.claude`       | Claude Code 클라이언트 이미지 (LMS 직결)                                                                   |
| `entrypoint.sh`           | claude PID1: `settings.json` 생성 + LMS 대기                                                               |
| `docker-compose.yml`      | `lms` + `claude` 2서비스, 내부 네트워크, healthcheck                                                       |
| `docker-compose.gpu.yml`  | GPU override (`runtime: nvidia`)                                                                           |
| `docker-compose.code.yml` | 호스트 코드 폴더 마운트 override                                                                           |
| `docker-compose.host.yml` | **호스트 직접 설치 LMS 용** claude 테스트 컨테이너 단독 기동 (lms 컨테이너 없음, 아래 섹션)                 |
| `.env.org`                | 파라미터 템플릿 (`cp .env.org .env` 후 사용)                                                               |
| `vscode-connect.sh`       | **[patch]** Linux/macOS 호스트의 Claude Code(CLI·VSCode 확장)를 LMS 에 직결/해제 ([PATCH.md](PATCH.md))    |
| `vscode-connect.ps1`      | **[patch]** **Windows 클라이언트**의 Claude Code 를 LAN 너머 LMS 에 직결/해제 (jq 불필요)                  |
| `lms-jinja-fix.sh`        | **[patch]** Jinja 템플릿 오류 진단·우회 (검증 모델 전환) — 6.lms_MultiLLM_run 최신판 이식                      |
| `PATCH.md`                | 위 패치 3종 사용법 (포트 publish·Windows 접속 절차 포함)                                                   |

---

## 호스트 LMS 테스트 컨테이너 (`docker-compose.host.yml`)

fg1 이 LMS 를 **호스트 직접 설치**([`DeviceManagement/fg1/lms/`](../../DeviceManagement/fg1/lms/))로 전환한 뒤,
호스트 서버(`0.0.0.0:1234`)를 검증·사용하는 claude 컨테이너만 단독 기동하는 구성 (2026-07-17 fg1 왕복 검증 ✅).

* lms 컨테이너 없음 — `host.docker.internal:host-gateway` 매핑으로 호스트 `lms-server.service` 직결
* 호스트 OS 의 `~/.claude` 설정 무변경 (컨테이너 내부 settings.json 만 LMS 직결)
* 모델 키는 **호스트 실측 키** 사용: `qwen3-coder-30b-a3b-instruct`(기본) | `gemma-4-26b-a4b-it`
  (컨테이너판 `qwen/qwen3-coder-30b` 와 다름. 전환은 `LMS_HOST_MODEL` 환경변수)
* `DeviceManagement/fg1/lms/test_claude.zsh` 와 같은 컨테이너명(`claude-lmstest`)을 사용 — 상호 재사용 가능

```bash
docker compose -f docker-compose.host.yml up -d    # 기동
docker exec -it claude-lmstest claude              # 에이전트 대화 (기본 qwen)
docker compose -f docker-compose.host.yml down     # 제거
```

---

## 빠른 시작

```bash
cp .env.org .env
vi .env                 # LMS_MODEL, LMS_MODEL_MOUNT 지정 (아래 .env 표 참조)

# 기본 기동 (CPU 가정)
docker compose up -d --build

# NVIDIA GPU 사용
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d --build

# 호스트 코드 폴더 마운트 (선택; .env 의 MOUNT_CODE_DIR 필요)
docker compose -f docker-compose.yml -f docker-compose.code.yml up -d --build

# 컨테이너 접속 후 Claude Code 실행
docker exec -it claude bash
cc                      # alias = claude --dangerously-skip-permissions

# 모델 수동 로드 (자동 로드 실패 시)
docker exec -it lms lms load <model>

# LMS 로그 확인 (PID1 이 'lms log stream' 기본 소스 = model: 프롬프트 입/출력)
docker logs -f lms

# LMS 서버 동작 실시간 관찰 — HTTP 요청 수신·프롬프트 진행률·토큰 속도(tok/s)까지
#   --source: model(기본) / server(HTTP·타이밍) / runtime. --stats·--json 옵션 병용 가능.
docker exec -it lms bash -lc 'lms log stream --source server'
#   예: [INFO] Running Anthropic messages API on conversation with 7 messages.
#       [INFO] Prompt processing progress: 86.7% ... prompt eval 574 tok/s, eval 88 tok/s
```

---

## .env 파라미터

| 변수                    | 기본값                        | 설명                                                                  |
| :---------------------- | :---------------------------- | :-------------------------------------------------------------------- |
| `LMS_MODEL`             | (모델 키)                     | `lms ls` 가 보여주는 소문자 hub 키. 예) `meta-llama-3.1-8b-instruct`. ANTHROPIC_MODEL 도 동일하게 전달됨 |
| `LMS_PORT`              | `1234`                        | LMS OpenAI 서버 포트                                                  |
| `LMS_BIND_HOST`         | `127.0.0.1`                   | 호스트 publish 바인드. `0.0.0.0` = LAN(Windows 클라이언트) 허용 ([PATCH.md](PATCH.md) §0) |
| `LMS_HEALTH_TRIES`      | `30`                          | `/v1/models` 헬스 폴링 최대 횟수(×2초)                                |
| `LMS_CONTEXT_LENGTH`    | `32768`                       | 컨텍스트 토큰 상한. Claude Code 에이전트 용도면 8192 로는 부족 → 32768↑ 권장 |
| `LMS_GPU`               | `max`                         | GPU offload 비율: `max`/`off`/`0~1`                                   |
| `LMS_PARALLEL`          | `1`                           | 동시 예측 슬롯 수. llmster 가 ctx 를 슬롯 수로 분할(32k/4→8k)해 Claude Code 시스템 프롬프트 초과 500 발생 → **1 필수** |
| `LMS_MODEL_MOUNT`       | (빈값)                        | 빈값=named volume(`lms-models`) / 호스트 경로=기존 모델 디렉토리 공유 |
| `API_TIMEOUT_MS`        | `600000`                      | claude↔LMS 타임아웃(ms). 소형 GPU 지연 대비                           |
| `LMS_CONTAINER_NAME`    | `lms`                         |                                                                       |
| `CLAUDE_CONTAINER_NAME` | `claude`                      |                                                                       |
| `LMS_NETWORK_NAME`      | `lms`                         |                                                                       |
| `COMPOSE_PROJECT_NAME`  | `air_gap_claude_code_lms_one` | 다중 인스턴스 충돌 회피                                               |
| `USER_UID` / `USER_GID` | `1000`                        | 호스트 파일 권한 일치 (`id -u`/`id -g`)                               |
| `TZ`                    | `Asia/Seoul`                  | 컨테이너 시각                                                         |
| `MOUNT_CODE_DIR`        | (빈값)                        | code override 용 호스트 코드 경로                                     |

---

## 호스트·Windows 클라이언트 접속 (patch)

컨테이너 `claude` 외에, **호스트나 다른 머신(Windows)의 Claude Code(CLI·VSCode 확장)** 도
publish 된 LMS 포트로 직결할 수 있다. 상세 절차·주의는 [`PATCH.md`](PATCH.md).

```bash
# 호스트(Linux/mac): ~/.claude/settings.json 병합 → LMS 직결
./vscode-connect.sh on            # off / status

# Windows(다른 머신): 서버 .env LMS_BIND_HOST=0.0.0.0 + 재기동 후, Windows 에서
#   .\vscode-connect.ps1 on -LmsHost <도커호스트IP> -Model <LMS_MODEL>

# Jinja 템플릿 오류(500 "Cannot perform operation ~ ...") 진단·우회
./lms-jinja-fix.sh probe          # verified / use <model> / status
```

* `entrypoint.lms.sh` 는 기동 시 **CUDA 런타임 자동 선택**(3.5)과 **`--parallel`**(기본 1)을
  적용한다 — llmster 는 CUDA 설치돼도 기본 SELECTED 가 CPU(avx2)일 수 있고(대형 모델 극저속),
  컨텍스트를 슬롯 수로 분할(기본 4)해 Claude Code 프롬프트가 슬롯을 초과(500)할 수 있다.
  둘 다 `6.lms_MultiLLM_run` 검증에서 확인된 사항의 백포트.

---

## 테스트 모델 권장 (context ≥128k)

| 모델                     | 크기    | context | 용도                               |
| :----------------------- | :------ | :------ | :--------------------------------- |
| `Phi-3.5-mini-instruct`  | 3.8B    | 128k    | 스모크(연결·기동) — 가장 빠른 왕복 |
| `Llama-3.1-8B-Instruct`  | 8B      | 128k    | 범용 안정 기준선                   |
| `DeepSeek-Coder-V2-Lite` | 16B MoE | 160k    | 코딩 검증 (MoE 로 빠름)            |

---

## ⚠️ 동작 한계 — 소형 모델의 에이전트 tool-use

실기동 검증 결과, **raw API 왕복**(`/v1/chat/completions`, `/v1/messages`)은 완벽히 동작하나, **`claude` CLI 의 대화형 에이전트 루프는 Llama-3.1-8B 급으로는 부적합**하다. 8B 모델이 Claude Code 의 도구 스키마를 받고 존재하지 않는 도구를 환각 호출(`No such tool available: edit/write/...`)→ 에러 재시도 무한 루프 → 응답 없음.

* 스모크/파이프라인 검증(연결·기동·API 왕복)엔 8B 로 충분.
* **에이전트(claude 대화) 용도는 tool-use 신뢰도 높은 더 큰/특화 모델** 권장 (예: Qwen2.5-Coder-32B 이상).

## air-gap(폐쇄망) 메모

* 현 구현은 **온라인 빌드 전제**(`Dockerfile.lms` 가 `install.sh` 로 `lms` 설치, entrypoint 가 `lms get` 으로 모델 다운로드).
* 폐쇄망 반입은 빌드 산출물을 그대로 옮기지 않고 docker `export`+`compose` 파이프라인으로 수행 — 외부망 빌드 → 매체 → 폐쇄망 import. `Dockerfile.lms` 에 오프라인 COPY 대안 라인이 주석으로 보존되어 있다.
* **버전 핀**: gemma chat template(jinja) 이슈 회피를 위해 LM Studio/llmster 버전 고정 권장(검증 시 llmster `0.0.18`).

---

## 검증 상태 (jm4, 온라인 + NVIDIA GPU)

* ✅ `build` → `up -d`(+gpu): lms `healthy` → claude 기동
* ✅ 모델 다운로드(Meta-Llama-3.1-8B-Instruct GGUF Q4_K_M, 4.92GB) → GPU 로드(context 32768)
* ✅ `/v1/models`·`/v1/chat/completions`(OpenAI)·`/v1/messages`(**Anthropic 네이티브**) 모두 200
* ✅ claude 컨테이너 → `lms:1234` 크로스컨테이너 추론 왕복
* ✅ 무인 재기동: entrypoint 가 캐시 모델 자동 로드 → 왕복 성공
* ⚠️ `claude` 에이전트 루프는 8B 한계 (위 "동작 한계" 참조)
* 상세: [`_doc_work/report/lms-one-llm_report.md`](../../air-gap-claudeCode/_doc_work/report/lms-one-llm_report.md)
