# Ollama WebUI Docker Compose

이 프로젝트는 Ollama와 Open WebUI를 Docker Compose를 사용하여 쉽게 실행할 수 있도록 구성되어 있습니다.

## 요구사항

- Docker
- Docker Compose
- NVIDIA GPU (선택사항, GPU 가속을 원하는 경우)

## 설치 및 실행 방법

1. 필요한 디렉토리 생성:
```bash
mkdir -p ~/.ollama
```

2. Docker Compose 실행:
```bash
docker-compose up -d
```

3. 서비스 확인:
```bash
curl http://localhost:8080/
```

## GPU 사용하기 (선택사항)

NVIDIA GPU를 사용하려면:

1. NVIDIA Container Toolkit 설치:
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

2. `docker-compose.yml` 파일에서 GPU 설정 주석 해제:
```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]
```

3. 서비스 재시작:
```bash
docker-compose down
docker-compose up -d
```

## 서비스 정보

### Ollama
- 포트: 11400
- 컨테이너 이름: ollama
- 볼륨: ~/.ollama:/root/.ollama
- GPU 지원: 선택사항 (설정 필요)

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

## GPU 사용 확인
GPU가 정상적으로 인식되었는지 확인하려면:
```bash
docker exec -it ollama nvidia-smi
``` 