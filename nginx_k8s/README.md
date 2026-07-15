# Nginx Kubernetes 테스트 이미지
Docker Hub 공식 `nginx:1.30.3` 이미지를 기반으로, Docker Hub 푸시·Kubernetes 배포 테스트까지 다루는 예제 이미지입니다. (구 `nginx2` 폴더 — "nginx 버전2"로 오해되기 쉬워 `nginx_k8s`로 이름 변경)

## 빌드 및 실행

Docker 호스트에 소스를 복사하고 컨테이너를 빌드하여 실행합니다.

### 빌드
```bash
docker build --rm -t nowage/nginx .
```

### 실행
```bash
docker run -d --name n1 -p 8888:80 nowage/nginx
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

## Kubernetes 테스트 예제

### Docker Hub에 푸시
```bash
docker login
docker push nowage/nginx
```

### Kubernetes 배포
```bash
# 디플로이먼트 생성
kubectl create deployment --image=nowage/nginx --port=80 n1

# 서비스 노출
kubectl expose deploy n1 --type=NodePort

# NodePort 확인
echo nodePort : $(kubectl get svc n1 -o jsonpath="{.spec.ports[0].nodePort}")
```


