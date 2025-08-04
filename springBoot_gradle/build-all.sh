#!/bin/bash

# Spring Boot + Gradle 전체 빌드 스크립트
# JDK 17 이미지부터 순차적으로 빌드합니다.

set -e

PROJECT_ROOT="/Users/nowage/_git/__all/dockers"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Spring Boot + Gradle 전체 빌드 시작..."
echo "📁 현재 디렉토리: $CURRENT_DIR"

# 1단계: JDK 17 이미지 확인 및 빌드
echo ""
echo "📋 1단계: JDK 17 이미지 확인 중..."

if docker images | grep -q "nowage/jdk.*17"; then
    echo "✅ JDK 17 이미지가 이미 존재합니다."
    docker images | grep "nowage/jdk.*17"
else
    echo "❌ JDK 17 이미지가 없습니다. 빌드를 시작합니다..."
    
    JDK17_DIR="$PROJECT_ROOT/jdk17"
    if [ ! -d "$JDK17_DIR" ]; then
        echo "❌ 오류: JDK 17 디렉토리를 찾을 수 없습니다: $JDK17_DIR"
        exit 1
    fi
    
    echo "🔨 JDK 17 이미지 빌드 중..."
    cd "$JDK17_DIR"
    docker build -t nowage/jdk:17 .
    
    echo "✅ JDK 17 이미지 빌드 완료!"
    docker images | grep "nowage/jdk.*17"
fi

# 2단계: Spring Boot 애플리케이션 빌드 및 실행
echo ""
echo "📋 2단계: Spring Boot 애플리케이션 빌드 및 실행..."

cd "$CURRENT_DIR"

# 기존 컨테이너 정리
echo "🧹 기존 컨테이너 정리 중..."
./do.sh

# 컨테이너 시작 대기
echo "⏱️  컨테이너 시작 대기 중..."
sleep 3

# 상태 확인
echo ""
echo "📊 컨테이너 상태 확인:"
docker ps | grep sb1 || echo "❌ sb1 컨테이너를 찾을 수 없습니다."

# 서비스 테스트
echo ""
echo "🧪 서비스 테스트 중..."
sleep 2

if curl -f http://127.0.0.1:8080 > /dev/null 2>&1; then
    echo "✅ Spring Boot 애플리케이션이 정상적으로 실행 중입니다!"
    echo "🌐 접속 URL: http://localhost:8080"
else
    echo "❌ Spring Boot 애플리케이션 테스트 실패"
    echo "📋 컨테이너 로그를 확인하시기 바랍니다:"
    echo "   docker logs sb1"
    exit 1
fi

echo ""
echo "🎉 전체 빌드 및 실행이 완료되었습니다!"
echo "📝 유용한 명령어:"
echo "   - 애플리케이션 테스트: curl http://127.0.0.1:8080"
echo "   - 컨테이너 로그 보기: docker logs sb1"
echo "   - 컨테이너 정지: docker-compose down"