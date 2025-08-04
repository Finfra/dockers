# Ubuntu Spark Docker 이미지
Ubuntu 기반에 Spark가 설치된 Docker 이미지입니다. 사용자 생성 및 패스워드 설정을 지원합니다.

## 빌드 및 실행

Docker 호스트에 소스를 복사하고 컨테이너를 빌드하여 실행합니다.

### 사전 요구사항
`_prgs` 폴더에 `spark-2.2.0-bin-hadoop2.7.tgz` 파일을 다운로드해야 합니다.

### 빌드
```bash
docker build --rm -t nowage/spark .
```

### 실행
```bash
docker run -it --rm \
    --name s1 \
    -e USER=nowage -e PASSWD=nowage \
    -v ~/df:/df \
    -p 8081:8081 \
    -p 8080:8080 \
    -p 7077:7077 \
    nowage/spark
```

## 포트 정보
- **8080**: Spark Master Web UI
- **8081**: Spark Worker Web UI
- **7077**: Spark Master

## 환경 변수
- **USER**: 생성할 사용자명
- **PASSWD**: 사용자 패스워드

## 볼륨 마운트
- `~/df` 디렉토리가 컨테이너의 `/df` 디렉토리로 마운트

## 컨테이너 확인
```bash
docker ps
# CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
# ad2ad96e4b2f        nowage/spark      "/bin/bash"         7 seconds ago       Up 6 seconds                            s1
```

## 테스트 (사용자 전환)
```bash
su - nowage
```

## 접속 방법
- Spark Master Web UI: http://localhost:8080
- Spark Worker Web UI: http://localhost:8081

## 정리 (Rollback)
```bash
docker rm s1 -f
docker rmi nowage/spark
```
