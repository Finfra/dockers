#!/bin/bash
# docker-run 래퍼: build + run + test. 표준: _doc_arch/patterns/docker-run/
# 주의: README 이미지명이 nginx 와 동일(nowage/nginx) — 동시 사용 시 충돌 가능.
set -e
cd "$(dirname "$0")"
IMAGE="nowage/nginx"; NAME="n1"; PORT="8888:80"

docker build --rm -t "$IMAGE" .
docker rm "$NAME" -f 2>/dev/null || true
docker run -d --name "$NAME" -p "$PORT" "$IMAGE"
docker ps | grep "$NAME" || echo "❌ $NAME 미실행"
echo "테스트: curl localhost:8888 | 정리: docker rm $NAME -f && docker rmi $IMAGE"
