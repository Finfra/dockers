# 패치 사용법 — 호스트/Windows 클라이언트 연결 & Jinja 오류 우회

`4.lms_OneLLM` 스택(직결 — 게이트웨이 없음)에 붙는 **클라이언트 측 패치 3종**의 사용법.
`6.lms_MultiLLM_run` 의 최신 패치를 직결 구조(LMS `/v1` 직접)에 맞게 이식 + **Windows 클라이언트 판 추가**.

| 패치                                       | 대상                   | 역할                                                                        |
| :----------------------------------------- | :--------------------- | :-------------------------------------------------------------------------- |
| [`vscode-connect.sh`](vscode-connect.sh)   | Linux/macOS 호스트     | 호스트 **Claude Code(CLI·VSCode 확장)** 를 LMS(`<호스트>:1234`)에 직결/해제 |
| [`vscode-connect.ps1`](vscode-connect.ps1) | **Windows 클라이언트** | Windows 의 Claude Code 를 LAN 너머 LMS 서버에 직결/해제 (jq 불필요)         |
| [`lms-jinja-fix.sh`](lms-jinja-fix.sh)     | 서버(도커 호스트)      | LLM 호출 시 **Jinja 템플릿 오류** 진단·우회 (검증 모델로 전환)              |

> 전제: `docker compose up -d` 로 스택이 떠 있고, LMS 포트가 호스트에 publish 되어 있어야 함
> (`.env` 의 `LMS_BIND_HOST` — 아래 §0). 파라미터는 같은 폴더 `.env` 에서 자동 로드(sh 계열).

---

## 0. 포트 publish — 외부 클라이언트 접근의 전제

`docker-compose.yml` 이 LMS 포트를 호스트에 publish 한다. 바인드 범위는 `.env` 로 제어:

| `.env` 설정                      | 접근 범위          | 용도                                            |
| :------------------------------- | :----------------- | :---------------------------------------------- |
| `LMS_BIND_HOST=127.0.0.1` (기본) | 도커 호스트 내부만 | 호스트 VSCode/CLI (`vscode-connect.sh`)         |
| `LMS_BIND_HOST=0.0.0.0`          | **LAN 전체**       | **Windows 등 다른 머신** (`vscode-connect.ps1`) |

```bash
vi .env                      # LMS_BIND_HOST=0.0.0.0 (Windows 클라이언트 허용 시)
docker compose up -d         # 재적용
curl http://<호스트IP>:1234/v1/models   # LAN 에서 확인
```

> ⚠️ LMS `/v1` 은 인증이 사실상 없다(더미 토큰). `0.0.0.0` 은 **폐쇄망/신뢰 LAN 전제**로만 사용하고,
> 필요 시 호스트 방화벽(ufw 등)에서 접근 소스를 제한할 것.

---

## 1. `vscode-connect.sh` — Linux/macOS 호스트 연결

VSCode 의 Claude Code 확장은 CLI 와 동일하게 `~/.claude/settings.json` 을 읽는다. 이 스크립트가
거기에 아래를 **병합**(기존 키 보존)한다 — 컨테이너 `claude` 의 환경과 동일하게 맞춘 것:

| 키                                             | 값                             | 이유                                              |
| :--------------------------------------------- | :----------------------------- | :------------------------------------------------ |
| `env.ANTHROPIC_BASE_URL`                       | `http://<LMS_HOST>:<LMS_PORT>` | LMS `/v1` 직결 (게이트웨이 없음)                  |
| `env.ANTHROPIC_AUTH_TOKEN`                     | `lms`                          | LMS 더미 토큰                                     |
| `env.API_TIMEOUT_MS`                           | `600000` (`.env` 값)           | **로컬 추론이 느려 첫 응답 지연 → 타임아웃 방지** |
| `env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `1`                            | 비-Anthropic 엔드포인트에 불필요 트래픽 차단      |
| `model`                                        | `<LMS_MODEL>`                  | 사용 모델 키                                      |

```bash
./vscode-connect.sh on        # 연결 (최초 실행 시 settings.json.bak 백업)
./vscode-connect.sh status    # 현재 설정 + LMS 모델 목록
./vscode-connect.sh off       # 우리가 넣은 키만 제거 → Anthropic 복귀
```

적용 후 **VSCode 명령팔레트 → `Developer: Reload Window`** (또는 확장 재시작).

**옵션**

| 상황                                  | 명령                                                                 |
| :------------------------------------ | :------------------------------------------------------------------- |
| 다른 머신에서 접속(Linux/mac)         | `LMS_HOST=<도커호스트IP> ./vscode-connect.sh on`                     |
| 워크스페이스에만 적용(전역 오염 회피) | `CLAUDE_SETTINGS=.claude/settings.local.json ./vscode-connect.sh on` |

> ⚠️ 기본 대상이 **전역** `~/.claude/settings.json` 이라, `on` 은 호스트의 모든 Claude Code
> (CLI·확장)를 로컬 LMS 로 향하게 한다. 되돌리려면 `off` 또는
> `cp ~/.claude/settings.json.bak ~/.claude/settings.json`.

---

## 2. `vscode-connect.ps1` — Windows 클라이언트 연결

Windows 의 Claude Code(CLI·VSCode 확장)는 `%USERPROFILE%\.claude\settings.json` 을 읽는다.
이 스크립트가 §1 과 **동일한 키**를 병합한다. PowerShell 5.1+ 내장 JSON 처리 — **jq 등 별도 도구 불필요**.

**서버(리눅스 도커 호스트) 준비** — §0 참조: `LMS_BIND_HOST=0.0.0.0` + 재기동 + 방화벽 허용.

**Windows 에서** (이 파일 하나만 복사해 가면 됨):

```powershell
# 연결 — LMS 서버 IP 와 모델 키 지정 (.env 의 LMS_MODEL 과 동일해야 함)
.\vscode-connect.ps1 on -LmsHost 192.168.0.4 -Model meta-llama-3.1-8b-instruct

# 상태 확인 (설정 + LMS 모델 목록)
.\vscode-connect.ps1 status -LmsHost 192.168.0.4

# 해제 (우리가 넣은 키만 제거 → Anthropic 복귀)
.\vscode-connect.ps1 off -Model meta-llama-3.1-8b-instruct
```

적용 후 **VSCode `Developer: Reload Window`** (또는 새 터미널에서 `claude` 재실행).

**옵션·비고**

| 상황                     | 방법                                                                                 |
| :----------------------- | :----------------------------------------------------------------------------------- |
| 실행 정책 오류           | `powershell -ExecutionPolicy Bypass -File .\vscode-connect.ps1 on ...`               |
| 포트가 기본(1234)과 다름 | `-Port 8080`                                                                         |
| 워크스페이스에만 적용    | `-SettingsPath .claude\settings.local.json`                                          |
| 파라미터를 env 로        | `$env:LMS_HOST`, `$env:LMS_MODEL`, `$env:LMS_PORT` 설정 후 `.\vscode-connect.ps1 on` |
| WSL/Git-Bash 사용자      | §1 의 `vscode-connect.sh` 를 `LMS_HOST=<서버IP>` 로 그대로 사용 가능                 |

> ⚠️ `on` 은 전역 설정 변경 — 이 Windows 머신의 모든 Claude Code 가 LMS 로 향한다.
> 최초 실행 시 `settings.json.bak` 을 백업하며, `off` 가 우리가 넣은 키만 제거한다.

---

## 3. `lms-jinja-fix.sh` — Jinja 템플릿 오류 우회

### 증상

일부 모델에서 Claude Code 호출 시 아래 오류가 난다 (컨테이너 `claude` 든 호스트/Windows 클라이언트든 동일):

```
500 {"error":{"message":"Error rendering prompt with jinja template:
     \"Cannot perform operation ~ on undefined values\" ..."}}
```

모델의 embedded **Jinja chat template** 이 Claude Code 의 `tools`/`system` 페이로드를
렌더하지 못해 발생한다. (참고: `LM_Studio_Ubuntu_Headless.md` Troubleshooting)

### 진단·우회 (헤드리스 권장 = 검증 모델)

```bash
./lms-jinja-fix.sh verified          # 검증된 모델 목록 (jinja 오류 없음)
./lms-jinja-fix.sh probe             # 현재 로드 모델 진단 (tools 포함 요청 → 오류 여부)
./lms-jinja-fix.sh probe <model>     # 특정 모델 진단
./lms-jinja-fix.sh use <model>       # 언로드 후 검증 모델 로드
./lms-jinja-fix.sh status            # 로드 상태
```

> ⚠️ **대형 모델이 "느린" 것은 jinja 가 아니라 GPU offload 미동작(CPU 추론)일 수 있다.**
> llmster 는 CUDA 런타임을 설치해도 기본 SELECTED 가 CPU(avx2)인 경우가 있음 → 이 폴더의
> `entrypoint.lms.sh` 가 기동 시 CUDA 런타임을 자동 선택하도록 패치됨(3.5 단계). 진단·상세는
> [`../../air-gap-claudeCode/6.lms_MultiLLM_run/info_jinja_and_lms.md`](../../air-gap-claudeCode/6.lms_MultiLLM_run/info_jinja_and_lms.md) 참조.

### 고급: prompt template 직접 편집 (문제 모델을 꼭 써야 할 때)

헤드리스 CLI(`lms load`)에는 템플릿 override 플래그가 없다. 템플릿 편집은 **LM Studio GUI** 가
가장 확실하다:

* My Models → 해당 모델 → ⚙️ → **Prompt Template** 탭
* `| string` 필터가 있는 라인에서 필터 제거: `{{ tool | string }}` → `{{ tool }}`
* 렌더 실패가 계속되면 모델 계열에 맞는 템플릿으로 통째 교체 (예: Nemotron 계열 템플릿은
  참고 문서 `LM_Studio_Ubuntu_Headless.md` 에 수록).

> GUI 가 없는 순수 headless 환경에서는 **검증 모델 전환(위 `use`)** 이 유일하게 안정적인 방법.

---

## 4. 권장 순서 (요약)

```bash
cd 4.lms_OneLLM

# 1) 스택 기동 (Windows 클라이언트 쓸 거면 .env LMS_BIND_HOST=0.0.0.0 먼저)
docker compose up -d --build          # (+gpu/+code override 는 README 참조)

# 2) jinja 오류 없는지 진단, 필요 시 검증 모델로 재로드
./lms-jinja-fix.sh probe
# (오류 시) ./lms-jinja-fix.sh use <검증모델>

# 3-a) 호스트(Linux/mac) 클라이언트 연결
./vscode-connect.sh on                # → VSCode: Developer: Reload Window
# 3-b) Windows 클라이언트 연결 (Windows 에서)
#   .\vscode-connect.ps1 on -LmsHost <도커호스트IP> -Model <LMS_MODEL>

# 4) 확인
./vscode-connect.sh status
```

---

## 참고

* 최신 패치 원본(게이트웨이판): [`../../air-gap-claudeCode/6.lms_MultiLLM_run/PATCH.md`](../../air-gap-claudeCode/6.lms_MultiLLM_run/PATCH.md),
  [`../../air-gap-claudeCode/6.lms_MultiLLM_run/info_jinja_and_lms.md`](../../air-gap-claudeCode/6.lms_MultiLLM_run/info_jinja_and_lms.md)
* 원 문서: `jm4:/Users/nowage/_doc/3.Resource/_LLM/Tools/LM_Studio_Ubuntu_Headless.md`
* 스택 구조·기동: 같은 폴더 [`README.md`](README.md)
