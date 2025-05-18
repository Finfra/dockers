# Ubuntu SSH

이 디렉토리는 Ubuntu 기반의 SSH 환경을 제공하는 docker-compose 설정 및 관련 파일을 포함하고 있습니다.

## 구성

- **docker/**: 도커 관련 설정 파일 및 스크립트
- **root/**: 컨테이너 내에서 사용할 사용자 환경 및 설정 파일

## 주요 기능

- SSH를 통한 Ubuntu 컨테이너 접속 및 테스트 환경 제공
- 개발, 테스트, 실습용 SSH 서버 환경

## 사용 방법

1. docker-compose로 컨테이너를 실행합니다.
   ```bash
   cd docker
   docker-compose up -d
   ```

2. 컨테이너에 SSH로 접속합니다.
   - SSH 클라이언트에서 아래와 같이 접속합니다.
     ```bash
     ssh [사용자명]@[호스트주소] -p [포트번호]
     ```
     `[사용자명]`, `[호스트주소]`, `[포트번호]`는 `docker-compose.yml` 및 환경설정에 따라 다를 수 있습니다.

3. 컨테이너에 직접 접속하려면:
   ```bash
   cd docker
   docker-compose exec [서비스명] bash
   ```
   `[서비스명]`에는 `docker-compose.yml`에 정의된 서비스 이름을 입력하세요.

## 참고

- SSH 키 및 비밀번호 등 민감 정보는 별도의 보안된 경로에 보관하세요.
- 필요에 따라 docker-compose 설정을 수정하여 포트, 사용자, 볼륨 등을 조정할 수 있습니다.
