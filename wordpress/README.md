# WordPress Docker 설정

이 프로젝트는 Docker를 사용하여 WordPress와 MySQL을 쉽게 실행할 수 있도록 구성되어 있습니다.

## 시스템 요구사항

- Docker
- Docker Compose

## 아키텍처별 실행 방법

### ARM64 (M1/M2 Mac) 환경
```bash
# docker-compose.yml 파일이 ARM64용으로 설정되어 있으므로 그대로 실행
docker-compose up -d
```

### x64 (Intel Mac, Windows, Linux) 환경
```bash
# docker-compose.yml 파일을 x64용으로 수정
sed -i '' 's/platform: linux\/arm64\/v8//g' docker-compose.yml
sed -i '' 's/mysql\/mysql-server:8.0/mysql:5.7/g' docker-compose.yml

# 컨테이너 실행
docker-compose up -d
```

## 설치 및 실행 방법

1. 프로젝트 디렉토리로 이동:
```bash
cd wordpress
```

2. 위의 아키텍처별 실행 방법에 따라 Docker 컨테이너 실행

3. 웹 브라우저에서 WordPress 접속:
```
http://localhost:8000
```

## 주요 설정

- WordPress 포트: 8000
- MySQL 데이터베이스 정보:
  - 데이터베이스 이름: wordpress
  - 사용자 이름: wordpress
  - 비밀번호: wordpress
  - 호스트: db

## 데이터 보존

- MySQL 데이터는 `db_data` 볼륨에 저장됩니다.
- WordPress 파일은 `wordpress_data` 볼륨에 저장됩니다.

## 컨테이너 중지

```bash
docker-compose down
```

## 볼륨 삭제

```bash
docker-compose down -v
``` 