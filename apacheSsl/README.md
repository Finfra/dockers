# SSL 테스트 프로젝트

이 프로젝트는 Docker 컨테이너에서 Nginx 웹서버를 실행하고 로컬 SSL 인증서를 사용하여 HTTPS 연결을 테스트합니다.

## 인증서 생성

인증서가 없는 경우 다음 명령어로 생성할 수 있습니다:

```bash
mkdir -p ~/.ssh/ssl
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
  -keyout ~/.ssh/ssl/server-key.pem \
  -out ~/.ssh/ssl/server-cert.pem \
  -subj "/CN=localhost"
```

## macOS 인증서 등록 (선택 사항)

개발 중 HTTPS 오류를 방지하기 위해 Keychain에 인증서를 등록할 수 있습니다:

```bash
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain ~/.ssh/ssl/server-cert.pem
```

## Docker 컨테이너 실행

프로젝트 루트 디렉토리에서 다음 명령어를 실행합니다:

```bash
docker compose up -d
```

## 테스트

HTTPS 연결을 테스트하려면 다음 명령어를 사용합니다:

```bash
curl -v https://localhost --cacert ~/.ssh/ssl/server-cert.pem
```

또는 웹 브라우저에서 `https://localhost`에 접속할 수 있습니다(처음 한번은 브라우저에서 인증서 보기에서 인증서 확인 안한다는 체크해야됨).

## 프로젝트 구조

- `docker-compose.yml`: Docker 컨테이너 설정
- `nginx/conf.d/default.conf`: Nginx SSL 설정
- `nginx/html/index.html`: 테스트용 웹 페이지 