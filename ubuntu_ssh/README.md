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

## SSH 키 설정 및 참고

- root 계정과 ubuntu 계정의 SSH 키 설정 상태가 다를 수 있습니다.
  - root 계정은 `../root` 디렉토리 내의 `authorized_keys` 파일을 사용합니다.
  - ubuntu 계정은 기본적으로 `authorized_keys`가 설정되어 있지 않을 수 있습니다.
- SSH 접속 시 키 인증을 위해서는 각 계정의 `~/.ssh/authorized_keys`에 공개키가 등록되어 있어야 합니다.
- 공개키를 등록하는 방법 예시:
  - `ssh-copy-id -i ssh/id_rsa.pub root@localhost -p 12222`
  - 또는 컨테이너 내 `/root/.ssh/authorized_keys` 파일에 직접 공개키를 추가
- 보안상 민감한 키 파일은 안전한 경로에 보관하고, 권한 설정에 주의하세요.

## 동작 확인

- 컨테이너가 정상 실행 중인지 확인합니다.
  ```bash
  cd docker
  docker-compose ps
  ```
- SSH 접속 테스트 예시:
  ```bash
  ssh -i ssh/id_rsa root@localhost -p 12222 hostname
  ssh -i ssh/id_rsa ubuntu@localhost -p 12222 hostname
  
  ```
  - 정상적으로 컨테이너 호스트명(`u1`)이 출력되면 SSH 접속이 성공한 것입니다.
  - 다른 계정(예: ubuntu)도 동일한 방식으로 접속 테스트할 수 있습니다.
