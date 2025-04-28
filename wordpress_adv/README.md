# WordPress 고급 Docker 설정

이 프로젝트는 Docker를 사용하여 WordPress와 MySQL을 자동으로 프로비저닝하는 고급 설정을 제공합니다.
단, PC나 Mac 환경에서는 WordPress 개발을 위해 Local by Flywheel이나 WP Studio와 같은 전용 개발 도구를 사용하는 것도 좋은 선택입니다. 이러한 도구들은 더 편리한 GUI 환경과 추가 기능들을 제공합니다.

## 시스템 요구사항

- Docker
- Docker Compose
- ~/.ssh/basic_pw 파일 (비밀번호 저장용)

## 설치 및 실행 방법

1. 스크립트 실행 권한 부여:
```bash
chmod +x install.sh clear.sh
```

2. 설치 스크립트 실행:
```bash
./install.sh
```
또는 모든 데이터를 초기화하고 설치:
```bash
./install.sh --clear
```

3. 모든 데이터 초기화:
```bash
./clear.sh
```

## 주요 특징

- 자동화된 WordPress 설치 프로세스
- HTTPS 지원 (자체 서명 인증서)
- 한국어 언어팩 자동 설치
- 환경 변수를 통한 설정 관리
- 응용 프로그램 비밀번호 지원
- 개발 환경 설정
- 아키텍처 자동 감지 (ARM64/x64)

## 디렉토리 구조

- `data/contents/`: WordPress 파일이 저장되는 디렉토리
- `data/wpDb1/`: MySQL 데이터가 저장되는 디렉토리
- `data/init/`: 초기화 스크립트와 설정 파일이 저장되는 디렉토리
- `wordpress/`: WordPress 컨테이너 설정 파일들

## 환경 설정

환경 변수는 .env 파일에서 관리됩니다:
- DB_ROOT_PASSWORD: MySQL root 비밀번호
- DB_NAME: 데이터베이스 이름
- DB_USER: 데이터베이스 사용자
- DB_PASSWORD: 데이터베이스 비밀번호
- WORDPRESS_URL: WordPress 사이트 URL
- WORDPRESS_TITLE: 사이트 제목
- WORDPRESS_ADMIN_USER: 관리자 사용자명
- WORDPRESS_ADMIN_PASSWORD: 관리자 비밀번호
- WORDPRESS_ADMIN_EMAIL: 관리자 이메일

## 접속 정보

- WordPress 사이트: https://localhost:8080
- WordPress 관리자: https://localhost:8080/wp-admin
- MySQL: localhost:3306

## SSL 인증서

개발 환경에서는 자체 서명된 SSL 인증서를 사용합니다. 브라우저에서 보안 경고가 표시될 수 있으며, 이는 개발 환경에서는 무시해도 됩니다.

## 데이터 초기화

`clear.sh` 스크립트를 사용하여 모든 데이터를 초기화할 수 있습니다:
```bash
./clear.sh
```

## 컨테이너 관리

컨테이너 중지:
```bash
docker-compose down
```
