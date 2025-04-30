# Ollama WebUI Docker Compose

이 프로젝트는 Ollama와 Open WebUI를 Docker Compose를 사용하여 쉽게 실행할 수 있도록 구성되어 있습니다. GPU 유무를 자동으로 감지하여 적절한 설정으로 실행됩니다.

## 요구사항

- Docker
- Docker Compose
- NVIDIA GPU (선택사항, GPU 가속을 원하는 경우)

## 설치 및 실행 방법

1. 스크립트에 실행 권한 부여:
```bash
chmod +x start.sh
```

2. 서비스 시작:
```bash
./start.sh
```

스크립트는 자동으로:
- 필요한 디렉토리를 생성합니다
- Docker 네트워크를 생성합니다
- GPU 유무를 감지하여 적절한 설정으로 서비스를 시작합니다

## 서비스 정보

### Ollama
- 포트: 11400
- 컨테이너 이름: ollama
- 볼륨: ~/.ollama:/root/.ollama
- GPU 지원: 자동 감지 및 설정

### WebUI
- 포트: 8080
- 컨테이너 이름: webui
- 볼륨: 
  - ~/.ollama:/root/.ollama
  - ./webui:/app/backend/data

## 네트워크
- 네트워크 이름: onet
- 서비스 간 통신을 위한 내부 네트워크

## 환경 변수
- OLLAMA_API_BASE_URL: http://ollama:11400

## 자동 재시작
- 모든 서비스는 `restart: always` 설정으로 자동 재시작됩니다.

## 모델 다운로드
Ollama를 통해 모델을 다운로드하려면:
```bash
docker exec -it ollama ollama pull [모델명]
```

예시:
```bash
docker exec -it ollama ollama pull llama2
```

## 접속
- WebUI: http://localhost:8080
- Ollama API: http://localhost:11400

## 서비스 관리

### 서비스 중지
```bash
docker-compose down
```

### 서비스 재시작
```bash
./start.sh
```

### 볼륨 포함하여 완전 삭제
```bash
docker-compose down --volumes
``` 