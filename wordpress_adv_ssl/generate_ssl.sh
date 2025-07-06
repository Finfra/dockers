#!/bin/bash

CERT_DIR="$HOME/.ssh/ssl"
KEY_FILE="$CERT_DIR/server-key.pem"
CSR_FILE="$CERT_DIR/server.csr"
CERT_FILE="$CERT_DIR/server-cert.pem"

# 기존 인증서 존재 여부 확인
if [[ -f "$KEY_FILE" || -f "$CERT_FILE" ]]; then
    echo "⚠️ 인증서 또는 키 파일이 이미 존재합니다. 생성하지 않음."
    echo "기존 파일:"
    [[ -f "$KEY_FILE" ]] && echo " - $KEY_FILE"
    [[ -f "$CERT_FILE" ]] && echo " - $CERT_FILE"
    exit 1
fi

# 디렉토리 생성
mkdir -p "$CERT_DIR"

# 개인 키 생성
openssl genrsa -out "$KEY_FILE" 2048

# CSR 생성
openssl req -new -key "$KEY_FILE" -out "$CSR_FILE" -subj "/C=KR/ST=Seoul/L=Gangnam/O=Finfra/CN=localhost"

# 자체 서명 인증서 생성 (유효기간 10년)
openssl x509 -req -days 3650 -in "$CSR_FILE" -signkey "$KEY_FILE" -out "$CERT_FILE"

# 권한 설정
chmod 600 "$KEY_FILE"
chmod 644 "$CERT_FILE"

echo "✅ SSL 인증서 생성 완료!"
echo "📂 위치: $CERT_DIR"