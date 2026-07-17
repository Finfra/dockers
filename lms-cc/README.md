# lms-cc

범용 **Claude Code** 컨테이너 이미지. 특정 LLM 백엔드에 하드코딩되지 않으며,
런타임 환경변수만으로 **LM Studio / Ollama / Anthropic 공식 API** 어디에든 연결할 수 있습니다.

- Docker Hub Repository: **https://hub.docker.com/r/finfra/lms-cc**
- 이미지: `finfra/lms-cc` (`docker pull finfra/lms-cc`)
- 기반: `debian:bookworm-slim` + Node.js 22 + `@anthropic-ai/claude-code`
- `ollama-claude/`, `lms_cc_all/` 의 Claude Code 컨테이너 공통부를 범용화한 이미지

## 환경변수

| 변수 | 설명 | 예 |
| --- | --- | --- |
| `ANTHROPIC_BASE_URL` | LLM 백엔드 주소. **미지정 시 Anthropic 공식 API** (claude 로그인 필요) | `http://lms:1234`, `http://ollama:11434` |
| `ANTHROPIC_AUTH_TOKEN` | 백엔드 인증 토큰 (로컬 백엔드는 임의 문자열, 기본 `dummy`) | `lms` |
| `ANTHROPIC_MODEL` | 사용할 모델명 | `qwen/qwen3-coder-30b` |
| `TZ` | 타임존 | `Asia/Seoul` |

`ANTHROPIC_BASE_URL` 지정 시 entrypoint 가 `~/.claude/settings.json` 을 매 기동마다 생성하고,
백엔드 호스트가 해석 가능하면 최대 120초 TCP 연결을 대기합니다.

## 빌드

```bash
docker build --rm -t finfra/lms-cc \
  --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) .
```

## 실행

```bash
# 1) Anthropic 공식 API 모드 (로그인 필요)
docker run -it --name cc finfra/lms-cc bash
# 컨테이너 안에서: claude  (또는 alias cc)

# 2) 로컬 LM Studio 백엔드 (같은 docker network 의 lms 컨테이너)
docker run -d --name cc --network claude-lms \
  -e ANTHROPIC_BASE_URL=http://lms:1234 \
  -e ANTHROPIC_AUTH_TOKEN=lms \
  -e ANTHROPIC_MODEL=qwen/qwen3-coder-30b \
  finfra/lms-cc

# 3) 로컬 Ollama 백엔드
docker run -d --name cc --network claude-ollama \
  -e ANTHROPIC_BASE_URL=http://ollama:11434 \
  -e ANTHROPIC_AUTH_TOKEN=ollama \
  -e ANTHROPIC_MODEL=qwen3-coder:30b \
  finfra/lms-cc

# 접속
docker exec -it cc bash
```

## 테스트

```bash
docker exec cc claude --version
docker exec cc cat /home/ubuntu/.claude/settings.json   # 백엔드 모드일 때
```

## Docker Hub 푸시

```bash
docker login
docker push finfra/lms-cc
```

## 정리

```bash
docker rm cc -f
docker rmi finfra/lms-cc
```
