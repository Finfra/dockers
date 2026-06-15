# WordPress 고급 Docker 설정

이 프로젝트는 Docker를 사용하여 WordPress와 MySQL을 자동으로 프로비저닝하는 고급 설정을 제공함. 
단, PC나 Mac 환경에서는 WordPress 개발을 위해 Local by Flywheel이나 WP Studio와 같은 전용 개발 도구를 사용하는 것도 좋은 선택임.  이러한 도구들은 더 편리한 GUI 환경과 추가 기능들을 제공함. 

## 시스템 요구사항

- Docker
- Docker Compose
- OpenSSL
- ~/.ssh/basic_pw 파일 (비밀번호 저장용)
 

## 설치 및 실행 방법

### ⚠️ 사전 준비

#### 1. 환경 변수 파일 설정
```bash
# .env.example 파일을 .env로 복사
cp .env.example .env

# .env 파일을 편집하여 실제 값으로 수정
vim .env  # 또는 원하는 에디터 사용
```

#### 2. SSL 인증서 생성
apacheSsl 프로젝트의 스크립트를 사용하거나 수동으로 생성할 수 있음 :

```bash
# apacheSsl 프로젝트의 자동 스크립트 사용 (권장)
../apacheSsl/generate-ssl.sh

# 또는 수동 생성
mkdir -p ~/.ssh/ssl
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
  -keyout ~/.ssh/ssl/server-key.pem \
  -out ~/.ssh/ssl/server-cert.pem \
  -subj "/CN=localhost"
```

### 실행 단계

1. 저장소 클론:
```bash
git clone <repository-url>
cd wordpress_adv_ssl
```

2. 컨테이너 시작:
```bash
./install.sh
```

## SSL 인증서 테스트

### 브라우저 테스트
1. 브라우저에서 다음 주소로 접속:
```
https://localhost:8443
```
2. 자체 서명 인증서를 사용하므로 보안 경고가 표시될 수 있음.  다음 단계로 진행:
   - "고급" 또는 "자세히" 클릭
   - "안전하지 않음으로 계속" 선택
   - 처음 접속 시에는 다음 단계도 필요:
     - "인증서 보기" 또는 "인증서 정보" 클릭
     - "항상 이 인증서 신뢰" 옵션 체크
     - "확인" 또는 "진행" 클릭

### 커맨드라인 테스트
curl 명령어로 SSL 연결을 테스트할 수 있음 :
```bash
curl -v https://localhost:8443 --cacert ~/.ssh/ssl/server-cert.pem
```

이 명령어는 다음 정보를 보여줌 :
- SSL 핸드셰이크 상세 정보
- 인증서 체인 검증 결과
- 서버 응답 내용

연결이 성공하면 다음 내용이 표시됨 :
- SSL 핸드셰이크 완료
- HTTP 응답 헤더
- WordPress 사이트의 HTML 내용

### 문제 해결
SSL 오류가 발생할 경우:
1. 인증서 파일 존재 확인:
```bash
ls -l ~/.ssh/ssl/
```
2. 인증서 상세 정보 확인:
```bash
openssl x509 -in ~/.ssh/ssl/server-cert.pem -text -noout
```
3. 컨테이너 재시작:
```bash
docker-compose down
docker-compose up -d
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

환경 변수는 .env 파일에서 관리됨 :
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

- WordPress 사이트: https://localhost:8443
- WordPress 관리자: https://localhost:8443/wp-admin
- MySQL: wpdb1
- Database Name: wordpress
- Database User: wordpress
## 응용 프로그램 비번 얻기
1. https://localhost:8443/wp-admin/users.php 접속
2. 유저 속성에서 "응용 프로그램 비밀번호" 생성
  - ![](./img/wp_ssh_pw.png)
  - ~/.ssh/wpAdminKey 파일에 저장해 둘 것.

## REST API를 통한 글 작성

### REST API 활성화
기본적으로 `wp-rest-api-controller` 플러그인이 REST API를 차단할 수 있습니다. 필요시 비활성화:

```bash
# REST API 차단 플러그인 비활성화
docker exec wp1 wp plugin deactivate wp-rest-api-controller --path=/var/www/html --allow-root

# WordPress 컨테이너 재시작
docker-compose restart wp1
```

### curl을 사용한 글 작성
```bash
# SSL 인증서를 사용한 REST API 글 작성
curl -X POST "https://localhost:8443/wp-json/wp/v2/posts" \
  --cacert ~/.ssh/ssl/server-cert.pem \
  -H "Content-Type: application/json" \
  -u "admin:[Application_Password]" \
  -d '{
    "title": "REST API로 작성한 글",
    "content": "REST API를 통해 작성한 포스트입니다.",
    "status": "publish"
  }'
```

### WP-CLI를 사용한 글 작성 (권장)
REST API가 차단된 경우 WP-CLI를 사용하여 직접 글 작성:

```bash
# Docker 컨테이너에서 WP-CLI로 글 작성
docker exec wp1 wp post create --path=/var/www/html --allow-root \
  --post_title="WP-CLI로 작성한 글" \
  --post_content="WP-CLI를 사용하여 작성한 포스트입니다." \
  --post_status=publish \
  --post_author=1

# 글 목록 확인
docker exec wp1 wp post list --path=/var/www/html --allow-root --format=table
```

### Application Password 사용법
1. WordPress 관리자 페이지에서 Application Password 생성
2. 생성된 키값을 curl 명령어에 사용
3. 형식: `admin:[키값]` (예: `admin:cijl yJux yVkb qo4x xrbT wF7e`)

### 주요 REST API 엔드포인트
- **글 목록 조회**: `GET /wp-json/wp/v2/posts`
- **글 작성**: `POST /wp-json/wp/v2/posts`
- **글 수정**: `PUT /wp-json/wp/v2/posts/{id}`
- **글 삭제**: `DELETE /wp-json/wp/v2/posts/{id}`

### 문제 해결
REST API가 작동하지 않는 경우:
1. `wp-rest-api-controller` 플러그인 비활성화 확인
2. Application Password 재생성
3. WordPress 컨테이너 재시작
4. WP-CLI 사용으로 대체


# SSL 인증서

## ~/.ssh/ssl에 SSL 인증서 생성 및 Keychain 등록
* generate_ssl.sh 스크립트를 사용하여 SSL 인증서를 생성하고 macOS Keychain에 등록함. 
* 개발 환경에서는 자체 서명된 SSL 인증서를 사용함.  브라우저에서 보안 경고가 표시될 수 있음.  이는 개발 환경에서는 무시해도 됨. 
### 브라우저에서 보안 경고 안뜨게
* 인증서 설정 ( ~/.ssh/ssl/server-cert.pem )을 Keychain에 등록하여 브라우저에서 보안 경고를 제거할 수 있음. 
  - ![](./img/ssl_setting1.png)

* 인증서 속성변경 업데이트 
  - ![](./img/ssl_setting2.png)



## cf. ssl 인증서 생성 및 Keychain 등록 방법
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

## 데이터 초기화

## 컨테이너 관리

컨테이너 중지:
```bash
docker-compose down
```

## 참고사항
- 이 설정은 개발 목적으로 자체 서명 인증서를 사용함 
- 프로덕션 환경에서는 신뢰할 수 있는 인증 기관(CA)에서 발급한 인증서를 사용하는 것이 좋음 
- 인증서는 기본적으로 10년간 유효함