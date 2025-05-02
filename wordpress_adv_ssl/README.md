# WordPress 고급 Docker 설정

이 프로젝트는 Docker를 사용하여 WordPress와 MySQL을 자동으로 프로비저닝하는 고급 설정을 제공합니다.
단, PC나 Mac 환경에서는 WordPress 개발을 위해 Local by Flywheel이나 WP Studio와 같은 전용 개발 도구를 사용하는 것도 좋은 선택입니다. 이러한 도구들은 더 편리한 GUI 환경과 추가 기능들을 제공합니다.

## 시스템 요구사항

- Docker
- Docker Compose
- ~/.ssh/basic_pw 파일 (비밀번호 저장용)

## 설치 및 실행 방법
```bash
./install.sh
```
또는 모든 데이터를 초기화하고 설치:
```bash
./install.sh --clear
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


## ~/.ssh/ssl에 SSL 인증서 생성 및 Keychain 등록
개발 환경에서는 자체 서명된 SSL 인증서를 사용합니다. 브라우저에서 보안 경고가 표시될 수 있으며, 이는 개발 환경에서는 무시해도 됩니다.

### 1. 디렉토리 생성
```bash
mkdir -p ~/.ssh/ssl
cd ~/.ssh/ssl
```

### 2. 사설 인증서 및 키 생성 (1년 유효)
```bash
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout server-key.pem \
  -out server-cert.pem \
  -subj "/C=KR/ST=Seoul/L=Gangnam/O=Finfra/CN=localhost"
```

### 3. 인증서 Keychain에 등록 (macOS Keychain Access에 추가)
```bash
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain \
  ~/.ssh/ssl/server-cert.pem
```

* `-d`: 인증서를 기본 신뢰로 설정
* `-r trustRoot`: 신뢰할 루트로 추가
* `-k`: 시스템 키체인 사용 (관리자 권한 필요)

### 4. 등록 확인 (GUI 또는 CLI)
* GUI: `Keychain Access.app` → 왼쪽 'System' 선택 → 인증서 목록 확인
* CLI:
```bash
security find-certificate -c localhost /Library/Keychains/System.keychain
```

### 5. 기타 권장 사항
* `.csr` 파일 필요 시 아래 명령으로 생성
```bash
openssl req -new -key server-key.pem -out server.csr \
  -subj "/C=KR/ST=Seoul/L=Gangnam/O=Finfra/CN=localhost"
```

* nginx나 Docker에서 사용 시 `server-key.pem`과 `server-cert.pem` 경로 마운트 필요

```


## 데이터 초기화


## 컨테이너 관리

컨테이너 중지:
```bash
docker-compose down
```
