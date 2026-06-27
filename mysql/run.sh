#!/bin/bash
# docker-run 래퍼: build + run(daemon). 표준: _doc_arch/patterns/docker-run/
set -e
cd "$(dirname "$0")"
IMAGE="nowage/mysql"; NAME="m1"

docker build --rm -t "$IMAGE" .
docker rm "$NAME" -f 2>/dev/null || true
docker run -d --name "$NAME" \
    -p 8081:8080 -p 3307:3306 \
    -v ~/df/Mysql/data:/var/lib/mysql/ \
    -v ~/df/Mysql/work:/root/work \
    -e MYSQL_ROOT_PASSWORD=nowage \
    "$IMAGE"
docker ps | grep "$NAME" || echo "❌ $NAME 미실행"
echo "로그: docker logs -f $NAME | 정리: docker rm $NAME -f && docker rmi $IMAGE"
