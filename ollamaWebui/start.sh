#!/bin/bash

# 필요한 디렉토리 생성
mkdir -p ~/.ollama
mkdir -p ./webui

# 네트워크 생성
docker network create onet 2>/dev/null || true

# GPU 확인
if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA GPU가 감지되었습니다. GPU 모드로 실행합니다."
    docker-compose -f docker-compose.gpu.yml up -d
else
    echo "NVIDIA GPU가 감지되지 않았습니다. CPU 모드로 실행합니다."
    docker-compose up -d
fi

# 서비스 확인
echo "서비스가 시작되었습니다. 잠시 후 다음 URL에서 접속 가능합니다:"
echo "WebUI: http://localhost:8080"
echo "Ollama API: http://localhost:11400" 