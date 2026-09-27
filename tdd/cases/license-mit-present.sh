#!/usr/bin/env bash
# 재생목록 #8 license-mit-present
# 루트 LICENSE 가 MIT 원문(저작권 승계 줄 포함)이고, README 라이선스 절이 MIT 를 명시하며 LICENSE 를 링크하고,
# "All rights reserved" 표기가 README* 에 남지 않는지 검증한다 (Issue19 — 라이선스 프로파일 C)
# 사용: tdd/cases/license-mit-present.sh [repo 루트]   (기본: 이 스크립트 기준 ../..)
set -u

ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$ROOT" || exit 2

pass=0; fail=0
ok()   { echo "ok   $1"; pass=$((pass+1)); }
bad()  { echo "FAIL $1"; fail=$((fail+1)); }

# 1) LICENSE 존재 + MIT 원문 식별 문구 + 저작권 승계 줄
if [ ! -f LICENSE ]; then
    bad "LICENSE — 파일 없음"
else
    grep -q '^MIT License$' LICENSE \
        && ok "LICENSE — MIT 원문 헤더" || bad "LICENSE — 'MIT License' 헤더 없음"
    grep -q '^Copyright (c) 2005-2026 Finfra$' LICENSE \
        && ok "LICENSE — 저작권 줄 승계 (2005-2026 Finfra)" || bad "LICENSE — 저작권 줄 'Copyright (c) 2005-2026 Finfra' 없음"
    grep -q 'THE SOFTWARE IS PROVIDED "AS IS"' LICENSE \
        && ok "LICENSE — 보증 부인 조항" || bad "LICENSE — 보증 부인 조항 없음(원문 훼손 의심)"
fi

# 2) README 라이선스 절: MIT 명시 + LICENSE 링크
sect=$(awk '/^## 저작권 및 라이선스/{f=1;next} /^## /{f=0} f' README.md)
if [ -z "$sect" ]; then
    bad "README.md — '## 저작권 및 라이선스' 절 없음"
else
    printf '%s\n' "$sect" | grep -q 'MIT' \
        && ok "README.md — 라이선스 절에 MIT 명시" || bad "README.md — 라이선스 절에 MIT 없음"
    printf '%s\n' "$sect" | grep -qE '\]\(LICENSE\)' \
        && ok "README.md — 라이선스 절이 LICENSE 를 링크" || bad "README.md — 라이선스 절에 [..](LICENSE) 링크 없음"
fi

# 3) 무표기·독점 표기 잔존 0건 (Issue19 검증 항목 그대로)
hits=$(grep -rn "All rights reserved" README* 2>/dev/null || true)
if [ -z "$hits" ]; then
    ok "README* — 'All rights reserved' 0건"
else
    bad "README* — 'All rights reserved' 잔존:"; printf '%s\n' "$hits"
fi

echo "---"
echo "license-mit-present: pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
