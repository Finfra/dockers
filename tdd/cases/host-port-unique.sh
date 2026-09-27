#!/usr/bin/env bash
# 재생목록 #2 host-port-unique
# git 추적 compose 파일 전부의 호스트 포트 매핑이 폴더 사이에서 겹치지 않는지 검증한다
# 같은 폴더의 compose 파일(ex: ollamaWebui 의 cpu/gpu 판)은 택일 변형이라 한 묶음으로 본다
# 사용: tdd/cases/host-port-unique.sh [repo 루트]   (기본: 이 스크립트 기준 ../..)
set -u

ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$ROOT" || exit 2

files=$(git ls-files | grep -E '(^|/)(docker-)?compose[^/]*\.ya?ml$' | grep -vE '(^|/)(\.history|_doc_[a-z]+)/')
if [ -z "$files" ]; then
    echo "FAIL: compose 파일이 하나도 없음 — 탐색 경로 오류"
    exit 1
fi

# 한 줄 = "<호스트포트>/<프로토콜> <폴더> <파일>:<서비스>"
map=""
for f in $files; do
    dir=$(dirname "$f")
    group=${dir%/docker}   # 중첩형(oracle-linux_ssh/docker 등)은 상위 폴더로 묶음
    # stdout = JSON, stderr = 경고(version obsolete 등) — 섞으면 JSON 파싱이 깨지므로 분리
    errf=$(mktemp)
    if ! json=$(cd "$dir" && docker compose -f "$(basename "$f")" config --format json 2>"$errf"); then
        echo "FAIL $f — compose config 실패 (재생목록 #1 먼저 확인)"
        sed 's/^/     /' "$errf"; rm -f "$errf"
        exit 1
    fi
    rm -f "$errf"
    rows=$(printf '%s' "$json" | python3 -c '
import json, sys
d = json.load(sys.stdin)
for name, svc in d.get("services", {}).items():
    for p in svc.get("ports", []):
        if p.get("published"):
            print("%s/%s %s" % (p["published"], p.get("protocol", "tcp"), name))
') || { echo "FAIL $f — 포트 파싱 실패"; exit 1; }
    while read -r port svc; do
        [ -n "$port" ] && map="$map$port $group $f:$svc"$'\n'
    done <<< "$rows"
done

# 포트별로 서로 다른 폴더가 2개 이상이면 충돌
conflicts=$(printf '%s' "$map" | sort -u | awk '
{ key=$1; if (!((key SUBSEP $2) in seen)) { seen[key SUBSEP $2]=1; n[key]++ } who[key]=who[key] " " $3 }
END { for (k in n) if (n[k] > 1) print k ":" who[k] }')

printf '%s' "$map" | sort -n | awk '{printf "     %-10s %s\n", $1, $3}'
echo "---"
if [ -n "$conflicts" ]; then
    echo "$conflicts" | sed 's/^/FAIL /'
    echo "host-port-unique: 충돌 $(echo "$conflicts" | wc -l | tr -d ' ')건"
    exit 1
fi
echo "host-port-unique: 충돌 0건 ($(printf '%s' "$map" | sort -u | wc -l | tr -d ' ')개 매핑)"
