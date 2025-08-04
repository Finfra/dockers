# Ubuntu 기본 Docker 이미지
Ubuntu 기반의 기본 Docker 이미지입니다.

## 빌드 및 실행

Docker 호스트에 소스를 복사하고 컨테이너를 빌드하여 실행합니다.

### 빌드
```bash
docker build --rm -t nowage/ubuntu:test .
```

### 실행
```bash
docker run -it --rm --name u1 nowage/ubuntu:test
```

## 컨테이너 확인
```bash
docker ps
# CONTAINER ID        IMAGE                COMMAND             CREATED             STATUS              PORTS               NAMES
# 63a0ba73bf81        nowage/ubuntu:test   "/bin/bash"         4 seconds ago       Up 3 seconds                            u1
```

## 테스트
```bash
tree
```

## 정리 (Rollback)
```bash
docker rm u1 -f 
docker rmi nowage/ubuntu:test
```
