# MySQL Docker 이미지
Python2/3가 추가된 MySQL Docker 이미지입니다.

# 빌드 및 실행

Docker 호스트에 소스를 복사하고 컨테이너를 빌드하여 실행합니다.

## 빌드
```bash
docker build --rm -t nowage/mysql .
```

## 데이터 디렉토리 준비
```bash
cname=mys

docker rm -f $cname
rm -rf ~/df/Mysql/data
rm -rf ~/df/Mysql/work
mkdir -p ~/df/Mysql/data
mkdir -p ~/df/Mysql/work
```

## 실행
```bash
docker run \
    -d \
    --rm \
    --name $cname \
    -p 8081:8080 \
    -p 3307:3306 \
    -v ~/df/Mysql/data:/var/lib/mysql/ \
    -v ~/df/Mysql/work:/root/work \
    -e MYSQL_ROOT_PASSWORD=nowage \
    nowage/mysql

docker logs -f $cname
```

## 포트 정보
- **8081**: 웹 인터페이스
- **3307**: MySQL 데이터베이스

## 컨테이너 확인
```bash
docker ps
# CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
# ad2ad96e4b2f        nowage/mysql      "/bin/bash"         7 seconds ago       Up 6 seconds                            mys
```

## 테스트 (MySQL 접속)
```bash
docker exec -it mys bash
# 컨테이너 내부에서:
mysql -uroot -p
# 패스워드: nowage
```

## 정리 (Rollback)
```bash
docker rm mys -f
docker rmi nowage/mysql
```
