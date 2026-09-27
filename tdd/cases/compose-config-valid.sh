#!/usr/bin/env bash
# 재생목록 #1 compose-config-valid
# git 추적 중인 compose 파일 전부에서 `docker compose config` 가 오류 없이 통과하는지 검증한다
# 사용: tdd/cases/compose-config-valid.sh [repo 루트]   (기본: 이 스크립트 기준 ../..)
set -u

ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$ROOT" || exit 2

# 대상 = git 추적 compose 파일 (.history·_doc_* 템플릿 제외)
files=$(git ls-files | grep -E '(^|/)(docker-)?compose[^/]*\.ya?ml$' | grep -vE '(^|/)(\.history|_doc_[a-z]+)/')
if [ -z "$files" ]; then
    echo "FAIL: compose 파일이 하나도 없음 — 탐색 경로 오류"
    exit 1
fi

pass=0; fail=0
for f in $files; do
    dir=$(dirname "$f")
    if out=$(cd "$dir" && docker compose -f "$(basename "$f")" config -q 2>&1); then
        echo "ok   $f"
        pass=$((pass+1))
    else
        echo "FAIL $f"
        echo "$out" | sed 's/^/     /'
        fail=$((fail+1))
    fi
done

echo "---"
echo "compose-config-valid: pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
