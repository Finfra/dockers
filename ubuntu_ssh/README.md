# Ubuntu SSH

이 디렉토리는 Ubuntu 기반의 SSH 환경을 제공하는 docker-compose 설정 및 관련 파일을 포함하고 있습니다.

## 구성

- **docker/**: 도커 관련 설정 파일 및 스크립트 (docker-compose.yml, Dockerfile 등)
- **root/**: 컨테이너 내에서 사용할 사용자 환경 및 설정 파일 (예: .bashrc, .profile)

## 주요 기능

- SSH를 통한 Ubuntu 컨테이너 접속 및 테스트 환경 제공
- 개발, 테스트, 실습용 SSH 서버 환경

## 사용 방법

1. docker-compose로 컨테이너를 빌드 및 실행합니다.
   ```bash
   cd docker
   docker-compose up -d --build
   ```
2. 컨테이너에 직접 접속하려면:
   ```bash
   cd docker
   docker-compose exec u1 bash
   ```

3. 컨테이너에 SSH로 접속합니다.
   - SSH 클라이언트에서 아래와 같이 접속합니다.
     ```bash
     ssh root@localhost -p 12222
     ```
     - 기본 사용자명은 `root`입니다.
     - 포트 번호 `12222`는 `docker-compose.yml`의 포트 매핑에 따라 다를 수 있습니다.
     - SSH 접속 시 비밀번호 또는 키 인증 방식을 사용할 수 있습니다.

## 상세 설정

- 컨테이너 이름 및 호스트명: `u1`
- 이미지: `nowage/ubuntu:ssh` (로컬 빌드)
- 볼륨 마운트:
  - `../root` → 컨테이너 내 `/root` (사용자 환경 설정 파일)
  - `~/df` → 컨테이너 내 `/df` (호스트의 df 디렉토리)
- 환경 변수:
  - `TZ=Asia/Seoul` (시간대 설정)
- 포트 매핑:
  - 호스트 `12222` → 컨테이너 `22` (SSH 접속 포트)

## 참고

- SSH 키 및 비밀번호 등 민감 정보는 별도의 보안된 경로에 보관하세요.
- 필요에 따라 `docker-compose.yml` 설정을 수정하여 포트, 사용자, 볼륨 등을 조정할 수 있습니다.
