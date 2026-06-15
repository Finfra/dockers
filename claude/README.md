# Claude Code 컨테이너 (Node 24)

Node.js 24 기반으로 Anthropic Claude Code CLI를 실행하는 Docker 환경입니다. 호스트의 소스 폴더를 컨테이너의 `/home/users/df` 로 마운트하여 격리된 환경에서 Claude Code를 사용합니다.

## 구성

| 파일 | 역할 |
| :----------------- | :--------------------------------------------- |
| `Dockerfile` | `node:24-bookworm` + Claude Code 전역 설치 |
| `docker-compose.yml` | 서비스·볼륨·환경변수 정의 |
| `entrypoint.sh` | 소유권 정렬 후 `ubuntu` 유저로 권한 드롭 |
| `.env` | 컨테이너 이름·소스 경로·UID/GID·API 키 설정 |
| `df/` | 소스 마운트 폴더 (`.gitignore` 로 제외) |

## 빌드 및 실행

```bash
cd claude
docker compose up -d --build
```

## 접속 (기본 유저: ubuntu)

초기 로그인 유저는 `ubuntu` 입니다. 작업 디렉토리는 `/home/users/df`.

```bash
docker compose exec claude bash
```

접속 후 Claude Code 실행:

```bash
claude          # 일반 실행
cc              # alias: claude --dangerously-skip-permissions
```

## root 로그인 방법

`ubuntu` 유저는 `sudo` (NOPASSWD) 권한을 가지므로 컨테이너 안에서 `sudo -i` 로 전환 가능합니다. 호스트에서 곧바로 root 셸로 접속하려면 `-u root` 옵션을 사용합니다.

```bash
# 방법 1: 호스트에서 root 셸로 직접 접속
docker compose exec -u root claude bash

# 방법 2: ubuntu 접속 후 root 전환
docker compose exec claude bash
sudo -i
```

## 소스 폴더 마운트

- 호스트 `./df` (또는 `.env` 의 `SOURCE_DIR`) → 컨테이너 `/home/users/df`
- 기본 마운트 폴더 `claude/df/` 는 저장소 `.gitignore` 에 등록되어 코드가 커밋되지 않습니다 (`.gitkeep` 만 추적).
- 다른 프로젝트를 마운트하려면 `.env` 에서 경로를 변경하세요:

```bash
# .env
SOURCE_DIR=~/myproject
```

## 인증 설정

두 가지 방법 중 선택합니다.

### 방법 1: 대화형 로그인 (권장)

```bash
docker compose exec claude bash
claude login
```

인증 결과는 `claude-home` 볼륨(`/home/ubuntu`)에 영속되어 컨테이너 재시작 후에도 유지됩니다.

### 방법 2: API 키

`.env` 의 `ANTHROPIC_API_KEY` 에 키를 입력하면 컨테이너 환경변수로 주입됩니다.

```bash
# .env
ANTHROPIC_API_KEY=sk-ant-...
```

## 환경 변수 (.env)

| 변수 | 기본값 | 설명 |
| :--------------------- | :-------------- | :--------------------------------------- |
| `COMPOSE_PROJECT_NAME` | `claude_code` | compose 프로젝트 이름 |
| `CLAUDE_CONTAINER_NAME`| `claude` | 컨테이너 이름 |
| `SOURCE_DIR` | `./df` | 호스트 소스 폴더 (컨테이너 `/home/users/df`) |
| `USER_UID` / `USER_GID`| `1000` | ubuntu 유저 UID/GID (호스트 권한 일치) |
| `ANTHROPIC_API_KEY` | (빈값) | API 키 인증 시 입력 |
| `TZ` | `Asia/Seoul` | 타임존 |

## 정리

```bash
# 컨테이너 중지·제거
docker compose down

# 인증 볼륨까지 완전 삭제
docker compose down -v
```

## 기여자 정보

- 작성자: NamJungGu <nowage@gmail.com>
- GitHub: https://github.com/Finfra/dockers
