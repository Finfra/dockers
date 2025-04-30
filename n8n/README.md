# n8n 서비스

n8n은 워크플로우 자동화 도구입니다.

## 환경 변수 설정

`.env` 파일에 다음 환경 변수를 설정해야 합니다:

```bash
N8N_USER=사용자명
N8N_HOST=호스트명
UID=사용자ID
```

## 볼륨 마운트

다음 디렉토리가 마운트됩니다:
- `../../3.src/fg1_n8n` -> `/home/node/.n8n/custom`: 커스텀 노드 및 설정
- `../../data/fg1_n8n` -> `/home/node/.n8n`: n8n 데이터
- `../../data/keys` -> `/app/keys`: SSH 키
- `../../data/html_buffer` -> `/home/node/html_buffer`: HTML 버퍼
- `../../data/log/n8n` -> `/home/node/log`: 로그 파일

## 포트

- 5678: n8n 웹 인터페이스

## 네트워크

- stnet 네트워크에 연결됨 