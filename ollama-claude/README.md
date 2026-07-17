# ollama-claude

로컬 **Ollama** 를 Anthropic 호환 백엔드로 사용하여, 인터넷/API 키 없이 **Claude Code** 를 구동하는 2-컨테이너(에어갭) 구성입니다.

- `ollama` 컨테이너: 모델 서빙 (지정 모델 자동 pull)
- `claude` 컨테이너: Claude Code CLI 설치 환경 (`ANTHROPIC_BASE_URL` 을 Ollama 로 지정)

## 요구사항
- Docker / Docker Compose
- NVIDIA GPU (선택 — 있으면 자동으로 GPU 모드)

## 빌드 및 실행
```bash
# 1) 환경값 준비 (모델·포트 등 수정 가능)
cp .env.sample .env

# 2) 시작 (GPU 자동 감지 + 이미지 빌드 + 모델 pull)
chmod +x start.sh clear.sh test-setup.sh
./start.sh
```

`start.sh` 는 자동으로:
- `.env` 가 없으면 `.env.sample` 로 생성
- NVIDIA GPU 감지 시 `docker-compose.gpu.yml` 적용
- `MOUNT_CODE_DIR` 지정 시 `docker-compose.code.yml` 적용
- 이미지 빌드 후 백그라운드 실행

## 사용 방법
```bash
# Claude 컨테이너 접속
docker exec -it claude-code bash

# Claude Code 실행 (alias: 권한 확인 스킵)
cc        # = claude --dangerously-skip-permissions
```

호스트 코드 폴더를 작업하려면 `.env` 의 `MOUNT_CODE_DIR` 를 지정 후 재실행하면
컨테이너 내 `/home/ubuntu/code` 로 마운트됩니다.

## 모델 변경
`.env` 의 `OLLAMA_MODEL` 값을 원하는 태그로 변경 (예: `qwen3-coder:30b`, `gemma3`, `llama3.1:8b`)
후 `./start.sh` 재실행. 수동 pull 도 가능:
```bash
docker exec -it ollama-claude ollama pull <모델명>
```

## 포트 정보
| 컨테이너     | 포트          | 용도               |
| ------------ | ------------- | ------------------ |
| ollama-claude | 11436 → 11434 | Ollama API         |
| claude-code  | (내부)        | Claude Code 실행기 |

> `ollamaWebui`(11434) 와 동시 실행 시 충돌을 피하기 위해 11436 을 기본 사용합니다.
> 변경하려면 `.env` 의 `OLLAMA_PORT` 수정.

## 테스트
```bash
./test-setup.sh
```
컨테이너 상태 · Ollama API · 모델 설치 · 네트워크 연결 · settings.json 을 점검합니다.

## 정리
```bash
./clear.sh            # 컨테이너 종료 (볼륨·모델 보존)
./clear.sh --volumes  # 볼륨(claude-home, ollama-models)까지 삭제
```

## 환경 변수 (.env)
| 변수                 | 기본값          | 설명                                   |
| -------------------- | --------------- | -------------------------------------- |
| OLLAMA_MODEL         | qwen3-coder:30b | 사용할 Ollama 모델 태그                |
| OLLAMA_MOUNT         | ollama-models   | 모델 저장소(named volume 또는 ~/.ollama) |
| MOUNT_CODE_DIR       | (없음)          | 호스트 코드 폴더 마운트 경로           |
| OLLAMA_PORT          | 11436           | 호스트 노출 포트                       |
| USER_UID / USER_GID  | 1000            | 컨테이너 ubuntu 유저 UID/GID           |
| OLLAMA_CONTEXT_LENGTH | 100000         | 컨텍스트 길이                          |
| TZ                   | Asia/Seoul      | 타임존                                 |

## 작성자
- NamJungGu <nowage@gmail.com>
