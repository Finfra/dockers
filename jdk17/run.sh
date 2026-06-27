#!/bin/bash
# docker-run 래퍼: build + run(interactive). 표준: _doc_arch/patterns/docker-run/
# 이 이미지(nowage/jdk:17)는 springBoot_gradle(compose)가 선행 의존.
set -e
cd "$(dirname "$0")"
IMAGE="nowage/jdk:17"; NAME="j1"

docker build -t "$IMAGE" .
exec docker run -it --name "$NAME" --rm -v ./../app:/app "$IMAGE"
