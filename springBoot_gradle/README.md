# Spring Boot + Gradle Docker 이미지
Spring Boot 애플리케이션을 Gradle로 빌드하고 실행하는 Docker 이미지입니다.

## ⚠️ 중요: 종속성 요구사항

이 이미지는 **JDK 17 이미지에 의존성**이 있습니다. 반드시 다음 순서로 빌드해야 합니다:

1. `jdk17` 이미지 빌드 (`nowage/jdk:17`)
2. `springBoot_gradle` 애플리케이션 빌드 및 실행

## 빌드 및 실행

### 🚀 자동 빌드 (권장)

종속성 이미지부터 자동으로 빌드하는 스크립트를 사용하세요:

```bash
./build-all.sh
```

이 스크립트는 다음 작업을 자동으로 수행합니다:
- JDK 17 이미지 존재 확인 및 자동 빌드
- Spring Boot 애플리케이션 빌드 및 실행
- 서비스 상태 확인 및 테스트
- 유용한 명령어 안내

### 🔧 수동 빌드

단계별로 수동 빌드를 원하는 경우:

#### 1단계: JDK 17 이미지 빌드
```bash
cd ../jdk17
docker build -t nowage/jdk:17 .
docker images | grep nowage/jdk
```

#### 2단계: Spring Boot 애플리케이션 빌드 및 실행
```bash
cd ../springBoot_gradle
./do.sh
```

### 테스트
애플리케이션이 실행된 후 테스트:
```bash
sleep 2
curl 127.0.0.1:8080
```

## 포트 정보
- **8080**: Spring Boot 애플리케이션

## 접속 방법
브라우저에서 다음 주소로 접속:
```
http://localhost:8080
```

## 정리

컨테이너와 이미지를 정리하려면:

```bash
# 컨테이너 정지 및 제거
docker-compose down --volumes

# 이미지 제거
docker rmi $(docker images | grep "springBoot_gradle" | awk '{print $3}')

# JDK 17 이미지도 제거하려면
docker rmi nowage/jdk:17
```

## 문제 해결

### "nowage/jdk:17" 이미지를 찾을 수 없음
```bash
# JDK 17 이미지가 없는 경우 먼저 빌드
cd ../jdk17
docker build -t nowage/jdk:17 .
```

### 포트 8080 이미 사용 중
다른 서비스가 8080 포트를 사용 중인 경우:
```bash
# 8080 포트를 사용하는 프로세스 확인
lsof -i :8080

# docker-compose.yaml에서 포트 변경 (예: 8081:8080)
```

## 사용된 기술
- Spring Boot
- Gradle  
- JDK 17
- Docker Compose