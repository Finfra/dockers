#!/usr/bin/env bash
# 재생목록 #6 spark-version-doc-match
# ubuntu_spark README·루트 CLAUDE.md 가 안내하는 Spark tgz 가 install.sh 가 요구하는 tgz 와 일치하는지 검증한다
# 기준(SSOT) = ubuntu_spark/install.sh 의 /_prgs/spark-*.tgz
# 사용: tdd/cases/spark-version-doc-match.sh [repo 루트]   (기본: 이 스크립트 기준 ../..)
set -u

ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$ROOT" || exit 2

want=$(grep -oE 'spark-[0-9][0-9.]*-bin-[a-z0-9.]+\.tgz' ubuntu_spark/install.sh | sort -u)
if [ "$(printf '%s\n' "$want" | grep -c .)" -ne 1 ]; then
    echo "FAIL: install.sh 요구 tgz 를 1개로 특정 못함: [$want]"
    exit 1
fi
echo "기준 (install.sh): $want"

pass=0; fail=0
# README 는 필수, 루트 CLAUDE.md 는 gitignore 로컬 파일이라 있을 때만 검사
for doc in ubuntu_spark/README.md CLAUDE.md; do
    if [ "$doc" = CLAUDE.md ] && [ ! -f "$doc" ]; then
        echo "skip $doc (로컬 파일 없음)"; continue
    fi
    got=$(grep -oE 'spark-[0-9][0-9.]*-bin-[a-z0-9.]+\.tgz' "$doc" | sort -u)
    if [ -z "$got" ]; then
        echo "FAIL $doc — Spark tgz 안내 없음"; fail=$((fail+1))
    elif [ "$got" = "$want" ]; then
        echo "ok   $doc"; pass=$((pass+1))
    else
        echo "FAIL $doc — 안내: $(echo $got)"; fail=$((fail+1))
    fi
done

echo "---"
echo "spark-version-doc-match: pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
