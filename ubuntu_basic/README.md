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

## 문제 해결

### `-d`(백그라운드)로 실행하면 바로 종료됨
* 원인: 이 이미지 CMD는 base(`ubuntu`) 기본값 `bash`(대화형 전용). TTY/STDIN 없이 `-d`만 주면 bash가 즉시 EOF → 컨테이너 종료
* 확인:
  ```bash
  docker run -d --name u1 nowage/ubuntu:test
  docker ps -a   # STATUS: Exited (0) N seconds ago
  ```
* 해결: 이 이미지는 `-it`(대화형) 전용으로 설계됨 — 위 "실행" 섹션대로 `-it --rm` 사용. 백그라운드 상시 컨테이너가 필요하면 `docker run -d ... nowage/ubuntu:test tail -f /dev/null` 로 PID1을 foreground 유지 프로세스로 오버라이드
* 상세: [_doc_arch/docker-migration-and-bootstrap-troubleshooting.md](../_doc_arch/docker-migration-and-bootstrap-troubleshooting.md)
