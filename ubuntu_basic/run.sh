#!/bin/bash
# docker-run 래퍼: build + run(interactive). 표준: _doc_arch/patterns/docker-run/
set -e
cd "$(dirname "$0")"
IMAGE="nowage/ubuntu:test"; NAME="u1"

docker build --rm -t "$IMAGE" .
exec docker run -it --rm --name "$NAME" "$IMAGE"
