#!/bin/bash
# docker-run 래퍼: build + run(interactive). 표준: _doc_arch/patterns/docker-run/
set -e
cd "$(dirname "$0")"
IMAGE="nowage/pyspark-tensorflow-notebook"; NAME="st"

docker build --rm -t "$IMAGE" .
exec docker run -it --rm -P --name "$NAME" \
    -p 8888:8888 -p 6006:6006 \
    -v ~/df:/notebooks/df \
    "$IMAGE"
