#!/bin/bash

# SSL 인증서 생성 스크립트
# 사용법: ./generate-ssl.sh

set -e

SSL_DIR="$HOME/.ssh/ssl"
CERT_FILE="$SSL_DIR/server-cert.pem"
KEY_FILE="$SSL_DIR/server-key.pem"

echo "🔐 SSL 인증서 생성 중..."

# SSL 디렉토리 생성
if [ ! -d "$SSL_DIR" ]; then
    echo "📁 디렉토리 생성: $SSL_DIR"
    mkdir -p "$SSL_DIR"
fi

# 기존 인증서 확인
if [ -f "$CERT_FILE" ] && [ -f "$KEY_FILE" ]; then
    echo "⚠️  기존 SSL 인증서가 발견되었습니다:"
    echo "   - $CERT_FILE"
    echo "   - $KEY_FILE"
    
    read -p "기존 인증서를 덮어쓰시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "✅ 기존 인증서를 사용합니다."
        exit 0
    fi
    
    echo "🗑️  기존 인증서 삭제 중..."
    rm -f "$CERT_FILE" "$KEY_FILE"
fi

# 새 인증서 생성
echo "🔑 새 SSL 인증서 생성 중..."
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
  -keyout "$KEY_FILE" \
  -out "$CERT_FILE" \
  -subj "/CN=localhost"

# 권한 설정
chmod 600 "$KEY_FILE"
chmod 644 "$CERT_FILE"

echo "✅ SSL 인증서가 성공적으로 생성되었습니다!"
echo "   - 인증서: $CERT_FILE"
echo "   - 개인키: $KEY_FILE"
echo ""

# macOS Keychain 등록 옵션
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 macOS 환경이 감지되었습니다."
    read -p "Keychain에 인증서를 등록하시겠습니까? (개발용으로 권장) (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔐 Keychain에 인증서 등록 중... (관리자 권한 필요)"
        sudo security add-trusted-cert -d -r trustRoot \
          -k /Library/Keychains/System.keychain "$CERT_FILE"
        echo "✅ Keychain에 인증서가 등록되었습니다."
    fi
fi

echo ""
echo "🚀 이제 다음 명령어로 Docker 컨테이너를 시작할 수 있습니다:"
echo "   docker compose up -d"
echo ""
echo "🌐 테스트 URL:"
echo "   https://localhost"
echo ""
echo "🧪 curl 테스트:"
echo "   curl -v https://localhost --cacert $CERT_FILE"