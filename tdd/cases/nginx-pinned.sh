#!/usr/bin/env bash
# 재생목록 #5 nginx-pinned
# nginx 예제(nginx·nginx_k8s) Dockerfile 의 FROM 이 무태그 없이 nginx:1.30.3 으로 고정되는지 검증한다
# 사용: tdd/cases/nginx-pinned.sh [repo 루트]   (기본: 이 스크립트 기준 ../..)
set -u

ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$ROOT" || exit 2

WANT="nginx:1.30.3"
files=$(git ls-files | grep -E '^nginx[^/]*/Dockerfile$')
if [ -z "$files" ]; then
    echo "FAIL: nginx Dockerfile 이 하나도 없음 — 탐색 경로 오류"
    exit 1
fi

pass=0; fail=0
for f in $files; do
    froms=$(grep -iE '^[[:space:]]*FROM[[:space:]]' "$f" | awk '{print $2}')
    if [ -z "$froms" ]; then
        echo "FAIL $f — FROM 없음"; fail=$((fail+1)); continue
    fi
    bad=""
    for img in $froms; do
        [ "$img" = "$WANT" ] || bad="$bad $img"
    done
    if [ -z "$bad" ]; then
        echo "ok   $f ($froms)"; pass=$((pass+1))
    else
        echo "FAIL $f — 기대 $WANT, 실제:$bad"; fail=$((fail+1))
    fi
done

echo "---"
echo "nginx-pinned: pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
