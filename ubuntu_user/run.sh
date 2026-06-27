#!/bin/bash
# docker-run 래퍼: build + run(interactive). 표준: _doc_arch/patterns/docker-run/
set -e
cd "$(dirname "$0")"
IMAGE="nowage/ubuntu"; NAME="u1"

docker build --rm -t "$IMAGE" .
docker rm "$NAME" -f 2>/dev/null || true
exec docker run -it --name "$NAME" -e USER=nowage -e PASSWD=nowage "$IMAGE"
