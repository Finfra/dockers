#!/bin/bash
# docker-run 래퍼: build + run(interactive). 표준: _doc_arch/patterns/docker-run/
set -e
cd "$(dirname "$0")"
IMAGE="nowage/tensorflow"; NAME="t1"

docker build --rm -t "$IMAGE" .
exec docker run -it --rm --name "$NAME" \
    -v ~/df:/notebooks/df \
    -v ~/TensorflowStudyExample:/notebooks/TensorflowStudyExample \
    -p 8888:8888 -p 2222:22 -p 6006:6006 \
    "$IMAGE"
