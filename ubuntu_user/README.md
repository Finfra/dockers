# Ubuntu 사용자 생성 Docker
Ubuntu 기반으로 사용자 생성 및 패스워드 설정을 지원하는 Docker 이미지입니다.

## 빌드 및 실행

Docker 호스트에 소스를 복사하고 컨테이너를 빌드하여 실행합니다.

### 빌드
```bash
docker build --rm -t nowage/ubuntu .
```

### 실행
```bash
docker run -it --name u1 -e USER=nowage -e PASSWD=nowage nowage/ubuntu
```

## 환경 변수
- **USER**: 생성할 사용자명
- **PASSWD**: 사용자 패스워드

## 컨테이너 확인
```bash
docker ps
# CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
# ad2ad96e4b2f        nowage/ubuntu      "/bin/bash"         7 seconds ago       Up 6 seconds                            u1
```

## 테스트 (사용자 전환)
```bash
su - nowage
```

## 정리 (Rollback)
```bash
docker rm u1 -f
docker rmi nowage/ubuntu
```
