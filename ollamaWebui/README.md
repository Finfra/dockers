# Ollama WebUI Docker Compose
* 이 프로젝트는 Ollama와 Open WebUI를 Docker Compose를 사용하여 쉽게 실행할 수 있도록 구성되어 있음.  
* GPU 유무를 자동으로 감지하여 적절한 설정으로 실행됨.
* ubuntu서버 등에서는 퍼미션 문제 주의

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

#### 볼륨 포함하여 완전 삭제
```bash
docker-compose down --volumes
```

## 권한 문제 해결

### Ubuntu 서버에서 권한 문제
Ubuntu 서버 환경에서 볼륨 마운트 시 권한 문제가 발생할 수 있습니다.

#### 증상
- 컨테이너 실행 후 파일 접근 권한 오류
- `Permission denied` 오류 메시지
- 볼륨 디렉토리에 파일 생성/수정 불가

#### 해결 방법

##### 1. 디렉토리 권한 설정
```bash
# 필요한 디렉토리 생성 및 권한 설정
mkdir -p ~/.ollama ./webui
chmod 755 ~/.ollama ./webui

# 소유권 설정 (필요한 경우)
sudo chown -R $USER:$USER ~/.ollama ./webui
```

##### 2. SELinux 비활성화 (CentOS/RHEL/Fedora)
SELinux가 활성화된 시스템에서는 추가 설정이 필요할 수 있습니다:
```bash
# SELinux 상태 확인
sestatus

# 일시적으로 비활성화 (재부팅 시 원복)
sudo setenforce 0

# 영구적으로 비활성화 (권장하지 않음)
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
```

##### 3. Docker 사용자 그룹 설정
```bash
# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 로그아웃 후 다시 로그인하거나 새 세션 시작
newgrp docker

# docker 그룹 멤버십 확인
groups $USER
```

##### 4. 볼륨 권한 문제 디버깅
```bash
# 컨테이너 내부에서 권한 확인
docker exec -it ollama ls -la /root/.ollama
docker exec -it webui ls -la /app/backend/data

# 호스트에서 권한 확인
ls -la ~/.ollama
ls -la ./webui
```

##### 5. 대안: Docker Compose 오버라이드 사용
권한 문제가 지속될 경우 `docker-compose.override.yml` 파일을 생성하여 사용자 ID를 명시적으로 설정할 수 있습니다:

```yaml
# docker-compose.override.yml
services:
  ollama:
    user: "${UID}:${GID}"
  webui:
    user: "${UID}:${GID}"
```

그 후 다음 명령어로 실행:
```bash
export UID=$(id -u)
export GID=$(id -g)
./start.sh
```

### 일반적인 권한 문제 예방
```bash
# 실행 전 권한 체크 스크립트
#!/bin/bash
echo "🔍 권한 체크 중..."

# 디렉토리 생성 및 권한 설정
mkdir -p ~/.ollama ./webui
chmod 755 ~/.ollama ./webui

# 현재 사용자 확인
echo "현재 사용자: $(whoami)"
echo "UID: $(id -u), GID: $(id -g)"

# Docker 그룹 멤버십 확인
if groups $USER | grep &>/dev/null '\bdocker\b'; then
    echo "✅ Docker 그룹 멤버십 확인됨"
else
    echo "❌ Docker 그룹에 속하지 않음. 다음 명령어 실행 후 재로그인:"
    echo "   sudo usermod -aG docker $USER"
fi

# 볼륨 디렉토리 권한 확인
echo "~/.ollama 권한: $(ls -ld ~/.ollama)"
echo "./webui 권한: $(ls -ld ./webui)"
``` 