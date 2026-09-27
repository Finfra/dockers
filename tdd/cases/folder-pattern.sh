#!/usr/bin/env bash
# 재생목록 #3 folder-pattern
# compose 폴더는 start.sh·clear.sh, run 폴더는 run.sh 를 가진다
# 제거된 build-all.sh 가 없고, run 폴더의 start.sh 는 Dockerfile 이 실제로 쓰는 것만 남는다(dead start.sh 금지)
# 사용: tdd/cases/folder-pattern.sh [repo 루트]   (기본: 이 스크립트 기준 ../..)
set -u

ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$ROOT" || exit 2

tracked=$(git ls-files)
has() { printf '%s\n' "$tracked" | grep -qx "$1"; }

# 예제 폴더 = Dockerfile 또는 compose 파일을 추적 중인 최상위 폴더
dirs=$(printf '%s\n' "$tracked" | grep -E '(^|/)(Dockerfile|(docker-)?compose[^/]*\.ya?ml)$' \
    | grep -vE '(^|/)(\.history|_doc_[a-z]+|tdd|worktrees)/' | grep / | cut -d/ -f1 | sort -u)
if [ -z "$dirs" ]; then
    echo "FAIL: 예제 폴더가 하나도 없음 — 탐색 경로 오류"
    exit 1
fi

pass=0; fail=0
for d in $dirs; do
    errs=""
    if printf '%s\n' "$tracked" | grep -qE "^$d/(docker/)?(docker-)?compose[^/]*\.ya?ml$"; then
        kind=compose
        has "$d/start.sh" || errs="$errs start.sh 없음;"
        has "$d/clear.sh" || errs="$errs clear.sh 없음;"
    else
        kind=run
        has "$d/run.sh" || errs="$errs run.sh 없음;"
        if has "$d/start.sh" && ! grep -qE '(COPY|ADD).*start\.sh' "$d/Dockerfile" 2>/dev/null; then
            errs="$errs Dockerfile 이 안 쓰는 dead start.sh;"
        fi
    fi
    has "$d/build-all.sh" && errs="$errs 제거된 build-all.sh 잔존;"
    if [ -z "$errs" ]; then
        echo "ok   $d ($kind)"; pass=$((pass+1))
    else
        echo "FAIL $d ($kind):$errs"; fail=$((fail+1))
    fi
done

# 폴더 밖(중첩 경로 포함) build-all.sh 잔존도 금지
stray=$(printf '%s\n' "$tracked" | grep -E '(^|/)build-all\.sh$' | grep -vE '(^|/)(\.history|_doc_[a-z]+)/')
if [ -n "$stray" ]; then
    echo "FAIL build-all.sh 잔존: $stray"; fail=$((fail+1))
fi

echo "---"
echo "folder-pattern: pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
