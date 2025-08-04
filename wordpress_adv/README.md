# WordPress 고급 Docker 설정

이 프로젝트는 Docker를 사용하여 WordPress와 MariaDB(MySQL 호환)를 자동으로 프로비저닝하는 고급 설정을 제공합니다.  
PC나 Mac 환경에서는 WordPress 개발을 위해 Local by Flywheel, WP Studio 등 전용 개발 도구도 좋은 선택입니다.

---

## 시스템 요구사항

- Docker, Docker Compose
- (Mac/ARM 사용자는 MariaDB가 x86_64 플랫폼으로 고정되어 있어 Rosetta 또는 x86_64 환경 필요)
- `~/.ssh/basic_pw` 파일 (비밀번호 저장용)

---

## 설치 및 실행 방법

### ⚠️ 사전 준비: 환경 변수 파일 설정

먼저 환경 변수 파일을 생성해야 합니다:

```bash
# .env.example 파일을 .env로 복사
cp .env.example .env

# .env 파일을 편집하여 실제 값으로 수정
vim .env  # 또는 원하는 에디터 사용
```

### 실행 단계

1. 모든 데이터 초기화:
    ```bash
    ./clear.sh
    ```

2. 설치 스크립트 실행:
    ```bash
    ./install.sh
    ```
    또는 모든 데이터를 초기화하고 설치:
    ```bash
    ./install.sh --clear
    # =     docker-compose up -d
    ```
3. WordPreess 접속
    ```
      open http://localhost:8080
    ```
4. WordPress Admin 접속
    ```
      open http://localhost:8080/wp-admin
    ```

5. 컨테이너 중지:
    ```bash
    docker-compose down
    ```

---

## 주요 특징

- 자동화된 WordPress + MariaDB 설치 프로세스
- HTTPS 지원 (자체 서명 인증서)
- 한국어 언어팩 자동 설치
- 환경 변수를 통한 설정 관리
- 응용 프로그램 비밀번호 지원
- 개발 환경 설정
- 아키텍처 자동 감지 (ARM64/x64, 단 DB는 x86_64 고정)
- 데이터 볼륨 분리 및 초기화 스크립트 지원

---

## docker-compose 서비스 구성

- **wpDb1**: MariaDB 10.11 (x86_64 고정)
    - 볼륨: `./data/wpDb1:/var/lib/mysql`, `./data/init:/docker-entrypoint-initdb.d`
    - 포트: `3307:3306` (호스트:컨테이너)
    - 환경 변수: `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`
- **wp1**: 커스텀 WordPress
    - 빌드: `./wordpress/Dockerfile`
    - 볼륨: `./data/contents:/var/www/html`, `./data/init:/data/init`
    - 포트: `8080:80` (호스트:컨테이너)
    - 환경 변수: `WORDPRESS_DB_HOST`, `WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, `WORDPRESS_DB_NAME` 등
- **네트워크**: `wnet` (bridge)

---

## 디렉토리 구조

- `data/contents/`: WordPress 파일 저장
- `data/wpDb1/`: MariaDB 데이터 저장
- `data/init/`: 초기화 스크립트 및 설정 파일
- `wordpress/`: WordPress 컨테이너 설정

---

## 환경 변수(.env 예시)

`.env` 파일 예시:
```env
DB_ROOT_PASSWORD=your_root_pw
DB_NAME=wordpress
DB_USER=wpuser
DB_PASSWORD=your_db_pw
WORDPRESS_URL=https://localhost:8080
WORDPRESS_TITLE=My WP Site
WORDPRESS_ADMIN_USER=admin
WORDPRESS_ADMIN_PASSWORD=your_admin_pw
WORDPRESS_ADMIN_EMAIL=admin@example.com
```

---

## 접속 정보

- WordPress 사이트: [https://localhost:8080](https://localhost:8080)
- WordPress 관리자: [https://localhost:8080/wp-admin](https://localhost:8080/wp-admin)
- MariaDB: `localhost:3307` (root/DB_USER 계정)

---

## SSL 인증서

개발 환경에서는 자체 서명된 SSL 인증서를 사용합니다. 브라우저에서 보안 경고가 표시될 수 있으며, 개발 환경에서는 무시해도 됩니다.

---

## 데이터 초기화

`clear.sh` 스크립트를 사용하여 모든 데이터를 초기화할 수 있습니다:
```bash
./clear.sh
```

---

## 문제 해결

- **Mac/ARM 환경에서 MariaDB 컨테이너가 실행되지 않을 경우**  
  → Rosetta 환경에서 Docker를 실행하거나, x86_64 기반 Docker Desktop을 사용하세요.
- **포트 충돌**  
  → 8080, 3307 포트가 이미 사용 중이면 docker-compose.yml에서 포트를 변경하세요.
- **.env 파일 누락**  
  → `.env` 파일이 없으면 컨테이너가 정상적으로 동작하지 않습니다.

---

## 참고

- [공식 WordPress Docker 문서](https://hub.docker.com/_/wordpress)
- [공식 MariaDB Docker 문서](https://hub.docker.com/_/mariadb)
