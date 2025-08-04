# TensorFlow Docker 이미지
tensorflow/tensorflow 기반의 TensorFlow Docker 이미지입니다.

## 버전 정보
- **TensorFlow**: 1.7
- **Python**: 3.5


## 빌드 및 실행

Docker 호스트에 소스를 복사하고 컨테이너를 빌드하여 실행합니다.

### 빌드
```bash
docker build --rm -t nowage/tensorflow .
```

### 실행
```bash
docker run -it --rm \
    --name=t1 \
    -v ~/df:/notebooks/df \
    -v ~/TensorflowStudyExample:/notebooks/TensorflowStudyExample \
    -p 8888:8888 \
    -p 2222:22 \
    -p 6006:6006 \
    nowage/tensorflow
```

## 포트 정보
- **8888**: Jupyter Notebook 웹 인터페이스
- **2222**: SSH
- **6006**: TensorBoard

## 볼륨 마운트
- `~/df` 디렉토리가 컨테이너의 `/notebooks/df` 디렉토리로 마운트
- `~/TensorflowStudyExample` 디렉토리가 컨테이너의 `/notebooks/TensorflowStudyExample` 디렉토리로 마운트

## 컨테이너 확인
```bash
docker ps
# CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS               NAMES
# ad2ad96e4b2f        nowage/tensorflow      "/bin/bash"         7 seconds ago       Up 6 seconds                            t1
```

## 접속 방법
브라우저에서 다음 주소로 접속:
```
http://localhost:8888
```

## 정리 (Rollback)
```bash
docker rm t1 -f
docker rmi nowage/tensorflow
```
