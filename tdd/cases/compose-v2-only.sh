#!/usr/bin/env bash
# 재생목록 #4 compose-v2-only
# git 추적 실행 스크립트(*.sh)에 docker-compose(v1) 호출이 없고 docker compose(v2)만 쓰는지 검증한다
# 파일명 docker-compose.yml 언급은 호출이 아니므로 제외한다. 주석 줄도 제외한다
# 사용: tdd/cases/compose-v2-only.sh [repo 루트]   (기본: 이 스크립트 기준 ../..)
set -u

ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$ROOT" || exit 2

scripts=$(git ls-files '*.sh' | grep -vE '(^|/)(\.history|_doc_[a-z]+|tdd)/')
if [ -z "$scripts" ]; then
    echo "FAIL: 실행 스크립트가 하나도 없음 — 탐색 경로 오류"
    exit 1
fi

# v1 호출 = docker-compose 뒤에 공백·줄끝·따옴표·세미콜론 (".yml" 등 파일명은 비매치)
hits=$(printf '%s\n' $scripts | xargs grep -nE 'docker-compose([[:space:]]|$|["'"'"';|&)])' \
    | grep -vE '^[^:]+:[0-9]+:[[:space:]]*#')

echo "검사 대상 스크립트 $(printf '%s\n' $scripts | wc -l | tr -d ' ')개"
echo "---"
if [ -n "$hits" ]; then
    echo "$hits" | sed 's/^/FAIL /'
    echo "compose-v2-only: v1 호출 $(echo "$hits" | wc -l | tr -d ' ')건"
    exit 1
fi
echo "compose-v2-only: v1 호출 0건"
