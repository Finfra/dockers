#!/bin/bash

# 인증서 저장 디렉토리 생성
mkdir -p ~/.ssh/ssl

# 개인 키 생성
openssl genrsa -out ~/.ssh/ssl/server-key.pem 2048

# CSR 생성
openssl req -new -key ~/.ssh/ssl/server-key.pem -out ~/.ssh/ssl/server.csr -subj "/C=KR/ST=Seoul/L=Gangnam/O=Finfra/CN=localhost"

# 자체 서명 인증서 생성 (유효기간 10년)
openssl x509 -req -days 3650 -in ~/.ssh/ssl/server.csr -signkey ~/.ssh/ssl/server-key.pem -out ~/.ssh/ssl/server-cert.pem

# 인증서 권한 설정
chmod 600 ~/.ssh/ssl/server-key.pem
chmod 644 ~/.ssh/ssl/server-cert.pem

echo "SSL 인증서 생성 완료!"
echo "인증서 위치: ~/.ssh/ssl/" 