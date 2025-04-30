# n8n 서비스

n8n은 워크플로우 자동화 도구입니다.

## 시작하기

1. 서비스 시작:
```bash
./start.sh
```

2. 워크플로우 가져오기:
```bash
./import_w1.sh
```

## 환경 변수 설정

`.env` 파일에 다음 환경 변수를 설정해야 합니다:

```bash
N8N_USER=사용자명
N8N_HOST=호스트명
N8N_WEBHOOK_URL=웹훅URL
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
N8N_RUNNERS_ENABLED=true
N8N_SECURE_COOKIE=false
N8N_USER_MANAGEMENT_DISABLED=true
N8N_BASIC_AUTH_ACTIVE=false
N8N_BASIC_AUTH_USER=사용자명
N8N_BASIC_AUTH_PASSWORD=비밀번호
N8N_API_KEY=API키
```

## API 키 설정

1. n8n 웹 인터페이스 접속 (http://localhost:5678)
2. Settings > API로 이동
3. API 키 생성
4. 생성된 API 키는 `import_w1.sh` 실행 시 자동으로 저장됨

## 볼륨 마운트

다음 디렉토리가 마운트됩니다:
- `./data/setting` -> `/home/node/.n8n`: n8n 설정 및 데이터
- `./data/share` -> `/home/node/share`: 공유 파일
- `./data/log` -> `/home/node/log`: 로그 파일
- `./data/contents` -> `/home/node/contents`: 컨텐츠 파일

## 워크플로우 테스트

웹훅 테스트:
```bash
curl -X POST "http://localhost:5678/webhook/webhook1" -H "Content-Type: application/json" -d '{"test": "data"}'
```

## 포트

- 5678: n8n 웹 인터페이스

## 네트워크

- stnet 네트워크에 연결됨 