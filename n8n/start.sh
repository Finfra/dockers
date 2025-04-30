#!/bin/bash

# .env 파일 경로
ENV_FILE=".env"

# 기본 비밀번호 파일 경로
BASIC_PW_FILE="$HOME/.ssh/basic_pw"

# SSH 키 파일 경로 (n8n setting 디렉토리)
SSH_KEY_FILE="data/setting/n8n_rsa"

# SSH 키가 없는 경우 생성
if [ ! -f "$SSH_KEY_FILE" ]; then
    echo "SSH 키가 없습니다. 새로 생성합니다..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_FILE" -N ""
fi

# API 키 생성 (SSH 키의 fingerprint 사용)
API_KEY="n8n_api_$(ssh-keygen -lf $SSH_KEY_FILE -E md5 | awk '{print $2}' | cut -d':' -f2)"

# .env 파일이 없거나 비밀번호가 없는 경우
if [ ! -f "$ENV_FILE" ] || ! grep -q "N8N_BASIC_AUTH_PASSWORD" "$ENV_FILE"; then
    # 기본 비밀번호 파일이 있는 경우
    if [ -f "$BASIC_PW_FILE" ]; then
        BASIC_PW=$(cat "$BASIC_PW_FILE")
    else
        # 비밀번호 입력 요청
        read -sp "n8n 기본 인증 비밀번호를 입력하세요: " BASIC_PW
        echo
    fi

    # .env 파일 생성
    cat > "$ENV_FILE" << EOF
N8N_USER=n8n
N8N_HOST=localhost
N8N_WEBHOOK_URL=http://localhost:5678
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
N8N_RUNNERS_ENABLED=true
N8N_SECURE_COOKIE=false
N8N_USER_MANAGEMENT_DISABLED=false
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=n8n
N8N_BASIC_AUTH_PASSWORD=$BASIC_PW
N8N_API_KEY=$API_KEY
N8N_PUBLIC_API_ENABLED=true
N8N_PUBLIC_API_DISABLED=false
N8N_API_KEY_ENABLED=true
EOF

    echo "API Key: $API_KEY"
fi

# 기존 컨테이너 중지 및 제거
docker-compose down --remove-orphans

# docker-compose 실행
docker-compose up -d 