# PySpark + TensorFlow Notebook Docker 이미지
Jupyter PySpark Notebook에 TensorFlow가 추가된 Docker 이미지입니다.

본 이미지는 Jupyter/pyspark-notebook에서는 지원되지 않는 sudo 명령을 지원하며 pyspark와 spark-submit 같은 명령을 지원합니다.

## 빌드 및 실행

Docker 호스트에 소스를 복사하고 컨테이너를 빌드하여 실행합니다.

### 빌드
```bash
docker build --rm -t nowage/pyspark-tensorflow-notebook .
```

### 기존 컨테이너 정리 및 실행
```bash
docker rm -f st
docker run \
    --name=st \
    --rm \
    -P -it \
    -p 8888:8888 \
    -p 6006:6006 \
    -v ~/df:/notebooks/df \
    nowage/pyspark-tensorflow-notebook
```

## 포트 정보
- **8888**: Jupyter Notebook 웹 인터페이스
- **6006**: TensorBoard
- **-P**: 모든 노출된 포트를 호스트의 임의 포트에 매핑

## 볼륨 마운트
- `~/df` 디렉토리가 컨테이너의 `/notebooks/df` 디렉토리로 마운트됩니다.

## 컨테이너 확인
```bash
docker ps
# CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
# ad2ad96e4b2f        nowage/pyspark-tensorflow-notebook "/bin/bash"         7 seconds ago       Up 6 seconds                            st
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
docker rm st -f
docker rmi nowage/pyspark-tensorflow-notebook
```
