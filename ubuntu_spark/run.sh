#!/bin/bash
# docker-run 래퍼: build + run(interactive). 표준: _doc_arch/patterns/docker-run/
# 사전 준비: _prgs/ 에 spark/hadoop tgz 다운로드 필요(README 참조).
set -e
cd "$(dirname "$0")"
IMAGE="nowage/spark"; NAME="s1"

docker build --rm -t "$IMAGE" .
exec docker run -it --rm --name "$NAME" \
    -e USER=nowage -e PASSWD=nowage \
    -v ~/df:/df \
    -p 8081:8081 -p 8080:8080 -p 7077:7077 \
    "$IMAGE"
