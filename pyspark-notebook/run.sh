#!/bin/bash
# docker-run 래퍼: build + run. 표준: _doc_arch/patterns/docker-run/
set -e
cd "$(dirname "$0")"
IMAGE="nowage/pyspark-notebook"; NAME="sp2"; PORT="8888:8888"

docker build --rm -t "$IMAGE" .
docker rm "$NAME" -f 2>/dev/null || true
docker run -d --name "$NAME" -p "$PORT" "$IMAGE"
docker ps | grep "$NAME" || echo "❌ $NAME 미실행"
echo "접속: http://localhost:8888 | 정리: docker rm $NAME -f && docker rmi $IMAGE"
