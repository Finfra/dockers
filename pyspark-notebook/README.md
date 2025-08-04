# PySpark Notebook Docker 이미지
Jupyter scipy-notebook 기반에 PySpark가 추가된 Docker 이미지입니다.

## 빌드 및 실행

Docker 호스트에 소스를 복사하고 컨테이너를 빌드하여 실행합니다.

### 빌드
```bash
docker build --rm -t nowage/pyspark-notebook .
```

### 실행
```bash
docker run -it --name sp2 -p 8888:8888 nowage/pyspark-notebook
```

## 포트 정보
- **8888**: Jupyter Notebook 웹 인터페이스

## 컨테이너 확인
```bash
docker ps
# CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
# ad2ad96e4b2f        nowage/pyspark-notebook "/bin/bash"         7 seconds ago       Up 6 seconds                            sp2
```

## 테스트
```bash
sudo su -
```

## 접속 방법
브라우저에서 다음 주소로 접속:
```
http://localhost:8888
```

## 정리 (Rollback)
```bash
docker rm sp2 -f
docker rmi nowage/pyspark-notebook
```
