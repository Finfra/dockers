# Ubuntu SSH Provisioner

이 디렉토리는 Ubuntu 기반의 SSH 프로비저닝 환경을 위한 docker-compose 설정 및 관련 파일을 포함하고 있습니다.

## 구성

- **docker/**: 도커 관련 설정 파일 및 스크립트
- **root/**

## 주요 기능

- SSH를 통한 원격 서버 접속 및 관리
- Ansible을 이용한 자동화된 서버 프로비저닝
- Terraform을 통한 인프라스트럭처 코드 관리

## 사용 방법

1. docker-compose로 컨테이너를 실행합니다.
   ```bash
   cd docker
   docker-compose up -d
   ```

2. 컨테이너에 접속합니다.
   ```bash
   cd docker
   docker-compose exec provisioner bash
   # 키설정
   ```
   `[서비스명]`에는 `docker-compose.yml`에 정의된 서비스 이름을 입력하세요.

4. ssh로 접속합니다. 
   ```
   ssh root@localhost -p12222
   ```

5. .ssh/config적용 예
   ```
   Host provisioner
      HostName 127.0.0.1
      Port 12222
      User root
   ```

6. Ansible 또는 Terraform 디렉토리로 이동하여 필요한 작업을 수행합니다.

## 참고

- SSH 키 및 민감 정보는 별도의 보안된 경로에 보관하세요.
- Ansible, Terraform 등은 각 디렉토리 내의 README를 참고하여 사용하세요.
