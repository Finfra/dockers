
# JDK 17 Docker 이미지

JDK 17이 설치된 Docker 이미지입니다.

## 빌드 및 테스트

### 빌드
```bash
# JDK 8
#docker build -t nowage/jdk:8.0 .

# JDK 17
docker build -t nowage/jdk:17 .

# JDK 21
#docker build -t nowage/jdk:21 .
```

### 실행
```bash
docker run -it --name j1 --rm -v ./../app:/app nowage/jdk:17
```

## 볼륨 마운트
- `./app` 디렉토리가 컨테이너의 `/app` 디렉토리로 마운트됩니다.

## 정리
```bash
# 컨테이너 자동 삭제 (--rm 옵션으로 자동 처리)
docker rmi nowage/jdk:17
```