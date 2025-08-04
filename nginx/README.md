# Nginx Docker 이미지
Docker용 Nginx 설치 이미지입니다.

## 빌드 및 실행

Docker 호스트에 소스를 복사하고 컨테이너를 빌드하여 실행합니다.

### 빌드
```bash
docker build --rm -t nowage/nginx .
```

### 실행
```bash
docker run -it --name n1 -p 8888:80 nowage/nginx
```

## 포트 정보
- **8888**: Nginx 웹 서버

## 컨테이너 확인
```bash
docker ps
# CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
# ad2ad96e4b2f        nowage/nginx      "/bin/bash"         7 seconds ago       Up 6 seconds                            n1
```

## 테스트
브라우저에서 다음 주소로 접속:
```
http://127.0.0.1:8888
```

## 정리 (Rollback)
```bash
docker rm n1 -f
docker rmi nowage/nginx
```
