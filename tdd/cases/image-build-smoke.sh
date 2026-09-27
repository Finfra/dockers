#!/usr/bin/env bash
# 재생목록 #7 image-build-smoke
# 과거 빌드 실패 이미지(ubuntu_user·pyspark-notebook)가 docker build 에 성공하고
# pyspark-notebook 컨테이너에 SPARK_HOME 이 설정되는지 검증한다 (Issue10·Issue11 회귀)
# ⚠️ Docker 데몬 필요 · 느림(수 분) — 재생목록 마지막 순서
# 사용: tdd/cases/image-build-smoke.sh [repo 루트]   (기본: 이 스크립트 기준 ../..)
set -u

ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$ROOT" || exit 2

if ! docker info >/dev/null 2>&1; then
    echo "FAIL: Docker 데몬에 연결 불가 — 데몬을 띄우고 다시 실행"
    exit 1
fi

TAG=tdd-smoke
pass=0; fail=0
for d in ubuntu_user pyspark-notebook; do
    img="$TAG/$(echo "$d" | tr 'A-Z_' 'a-z-')"
    if out=$(docker build --rm -q -t "$img" "$d" 2>&1); then
        echo "ok   build $d"; pass=$((pass+1))
    else
        echo "FAIL build $d"
        echo "$out" | tail -20 | sed 's/^/     /'
        fail=$((fail+1))
    fi
done

img="$TAG/pyspark-notebook"
if docker image inspect "$img" >/dev/null 2>&1; then
    spark_home=$(docker run --rm --entrypoint sh "$img" -c 'printf %s "$SPARK_HOME"' 2>&1)
    if [ -n "$spark_home" ] && docker run --rm --entrypoint sh "$img" -c 'test -d "$SPARK_HOME"'; then
        echo "ok   SPARK_HOME=$spark_home"; pass=$((pass+1))
    else
        echo "FAIL SPARK_HOME 미설정 또는 경로 없음: [$spark_home]"; fail=$((fail+1))
    fi
fi

# 테스트가 만든 이미지만 정리 (태그 접두 $TAG/ 한정)
docker rmi -f "$TAG/ubuntu-user" "$TAG/pyspark-notebook" >/dev/null 2>&1

echo "---"
echo "image-build-smoke: pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
