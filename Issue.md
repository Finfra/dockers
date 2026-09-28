---
title: dockers Issue
description: dockers 프로젝트 이슈 관리 파일 (내부 개발자용-public 이슈는 github이슈 사용)
date: 2026-06-26
---

# Issue Management
* Issue HWM: 20
* 설계·해결 기록: `_doc_arch/known-issues-resolution.md` (구 Issue.md, 2024-08 8/8 해결 완료)
* Checkpoints:
    - {git-hash} {date}

# 🤔 결정사항

# 🌱 이슈후보

1. `_doc_arch`/`_doc_work` gitignore 정책 재검토 — 설계 SSOT 변경이 커밋 이력에 남지 않아 이슈 종결 시 commit hash 를 만들 수 없음(Issue16 에서 실제 발생). remote 가 public 이라 단순 추적 전환은 불가 → 별도 private repo 분리·submodule·mirror 등 대안 검토 필요
2. `springBoot_gradle/do.sh`·`wordpress_adv_ssl/install.sh` 정리 + `wordpress_adv`/`wordpress_adv_ssl` 의 구 `.env.example` 제거
3. 폴더 README 6종의 `docker-compose`(v1) 표기를 `docker compose`(v2) 로 정규화
4. `ubuntu_ssh_provisioner/start.sh` 가 `DF_PATH` 를 공급하도록 수정 (`.env.sample` 추가 또는 `docker/docker-compose.sh` 로 위임)
5. 무태그 `FROM` 7종 고정 — `ubuntu_all`·`ubuntu_basic`·`ubuntu_spark`·`ubuntu_user`(`FROM ubuntu`), `mysql`·`tensorflow`·`pyspark-tensorflow-notebook` (Issue16 에서 무태그 금지 명문화, Issue18 빌드 스모크 중 확인) — 재생목록 `nginx-pinned` 처럼 전 폴더 대상 테스트로 확장 검토
6. 하위 폴더 `LICENSE` 10종 정리 — `ubuntu_all`·`ubuntu_basic`·`ubuntu_spark`·`ubuntu_ssh`·`ubuntu_ssh_provisioner`·`ubuntu_user`·`mysql`·`centos7_user`·`tensorflow`·`oracle-linux_ssh` 에 저작권자 미기입 GPLv2 원문(FSF 템플릿 그대로, 2020-06-27 `454b33c` 유입)이 남아 루트 MIT(Issue19)와 갈린다. prj6 license-profiles.md §5 규정상 하위 `LICENSE` 가 루트를 덮으므로 삭제(단일 MIT) 또는 의도 확인 필요 — 삭제는 사용자 승인 후
7. 재생목록 #7 `image-build-smoke` jma 재실행 — Issue20 에서 jma Docker Desktop 데몬 미기동으로 이관. jma GUI 에서 Docker Desktop 기동 후 `tdd/cases/image-build-smoke.sh` 실행(Docker Hub pull 은 keychain 우회 필요 — `_doc_work/debug_TECH.md` 2026-09-27)

# 🚧 진행중

# 📕 중요

# 📙 일반

# 📗 선택

# ✅ 완료

> 상세 해결 내역은 `_doc_arch/known-issues-resolution.md` 참조.

## Issue20: TDD 풀 재생 — 재생목록 ✅ 8행 1→8 실행·행별 rc·소요 기록 (등록: 2026-09-29, 해결: 2026-09-29) ✅
* 목적: `tdd/playlist.md` ✅ 8행을 재생 순서대로 `tdd/cases/<id>.sh` 각각 실행해 현 HEAD 의 회귀 상태를 기록 (prj5#Issue108 위임 · 러너 `run.sh` 없음)
* 상세:
    - 기준 HEAD `c9a813d` · #1~#6·#8 은 jm4, #7 은 jma 전용(jm4 docker build 금지)
    - 결과표

        | # | id | 실행처 | rc | 소요 | 요약 |
        | :- | :- | :- | :- | :- | :- |
        | 1 | `compose-config-valid` | jm4 | 0 | 3.2s | pass=12 fail=0 |
        | 2 | `host-port-unique` | jm4 | 0 | 3.5s | 충돌 0건 (16개 매핑) |
        | 3 | `folder-pattern` | jm4 | 0 | 0.3s | pass=23 fail=0 |
        | 4 | `compose-v2-only` | jm4 | 0 | 0.1s | v1 호출 0건 (스크립트 58개) |
        | 5 | `nginx-pinned` | jm4 | 0 | 0.0s | pass=2 fail=0 |
        | 6 | `spark-version-doc-match` | jm4 | 0 | 0.0s | pass=2 fail=0 |
        | 7 | `image-build-smoke` | jma | — | — | **미실행·이관** — jma SSH 접속은 되나 Docker Desktop 데몬 미기동(`~/.docker/run/docker.sock` 없음, `docker info` 연결 실패) |
        | 8 | `license-mit-present` | jm4 | 0 | 0.0s | pass=6 fail=0 |

* 구현 명세:
    - TDD 해당 없음: 기존 테스트 재생만 — 코드 변경 없음. red 0건이라 수정 이슈 없음
    - 결과: 실행 7/8 · green 7 · red 0 · red→fix 커밋 없음 · #7 이관(재실행은 이슈후보 7)
    - 금지 준수: jm4 docker build·`pkill -f`·push 미실행
## Issue19: 라이선스 프로파일 C — 저작권 한 줄뿐인 무표기 → MIT LICENSE 추가 (등록: 2026-09-27, 해결: 2026-09-27) ✅
* 목적: "(c) Copyright 2005-2024 by finfra.com" 한 줄뿐이라 법적으로 All rights reserved 다(10★ repo 인데 쓰면 안 되는 상태). 예제·스니펫은 제한이 채택만 줄인다
* 상세:
    - `LICENSE` = MIT 원문(저작권 줄은 기존 표기 승계 — `Copyright (c) 2005-2026 Finfra`)
    - README "저작권 및 라이선스" 절에 MIT 명시 + LICENSE 링크
    - 정본 `/Users/nowage/_git/___architect/_doc_arch/license-profiles.md` §4 row 71 · 템플릿 `/Users/nowage/_git/___architect/data/template/license/README.md`(자리표 값 표 포함 — `{{N}}`=250 · `{{LICENSOR}}`=`Finfra Co., Ltd. (https://finfra.kr)` · `{{CONTACT}}`=finfra@gmail.com)
* 구현 명세:
    - 검증: `LICENSE` 존재 · README 라이선스 절 링크 · `grep -rn "All rights reserved" README*` 0건
    - 금지: `git push`(공개 라이선스 변경은 사용자가 push) · npm publish · 기존 릴리스 태그 변경
    - `Issue.md` 는 `python3 ~/.claude/sh/issue-tx.py --file Issue.md stage --issues <N>` / `check` 경유 스테이징 · 커밋 후 ✅ 이동 + hash 기록
    - 결과: `LICENSE`(MIT 원문, `Copyright (c) 2005-2026 Finfra`) 신설 · README 「저작권 및 라이선스」 MIT 명시 + `[MIT License](LICENSE)` 링크 + 이미지 내 소프트웨어 각자 라이선스 고지 · 로컬 `CLAUDE.md` 동일 갱신(gitignore)
    - TDD: `tdd/cases/license-mit-present.sh` 신설(재생목록 #8) — LICENSE 부재 상태 red(fail=3) 확인 후 구현 → green(pass=6). #1~#6 회귀 exit 0 (#7 은 jma 전용, 미실행)
    - 검증 3항 통과: LICENSE 존재 · README 절 LICENSE 링크 · `grep -rn "All rights reserved" README*` 0건. push 미실행(사용자 몫)
    - 후속 발견: 하위 10개 폴더(`ubuntu_*`·`mysql`·`centos7_user`·`tensorflow`·`oracle-linux_ssh`)에 2020-06 유입된 **미기입 GPLv2 보일러플레이트 `LICENSE`** 잔존 — 루트 MIT 와 갈린다. 삭제는 승인 대상이라 이슈후보 6 으로 등록
* 커밋: 8103396

## Issue18: TDD 재생목록 #2~#7 구현 — 전 목표 green (등록: 2026-09-27, 해결: 2026-09-27) ✅
* 목적: `tdd/playlist.md` 남은 목표 6개(#2~#7)를 테스트로 고정해 재생목록 전 목표 green 달성 (prj5#Issue100 위임)
* 상세:
    - 테스트 신설 6종 `tdd/cases/`: `host-port-unique`·`folder-pattern`·`compose-v2-only`·`nginx-pinned`·`spark-version-doc-match`·`image-build-smoke`
    - red: #6 `spark-version-doc-match` — `ubuntu_spark/README.md`·`CLAUDE.md` 가 `spark-2.2.0-bin-hadoop2.7.tgz` 안내, `install.sh` 는 `spark-3.4.4-bin-hadoop3.tgz` 요구
    - #2~#5 는 현 코드가 이미 준수 → 임시 복사본에 결함 주입(포트 8083 중복·build-all.sh·clear.sh 삭제·dead start.sh·`docker-compose` 호출·무태그 `FROM nginx`)으로 전부 red 검출 확인 후 원복
* 구현 명세:
    - #6 green: README·CLAUDE.md 안내를 `spark-3.4.4-bin-hadoop3.tgz` 로 교정 + README 에 wget 명령 추가 (이슈후보 구2번 해소)
    - #2 는 같은 폴더의 compose 파일(ollamaWebui cpu/gpu)을 택일 변형으로 묶어 폴더 간 충돌만 판정. compose stderr 경고가 JSON 에 섞이지 않게 분리
    - #7 은 jma Docker Desktop 에서 실행: ubuntu_user·pyspark-notebook 빌드 성공, `SPARK_HOME=/usr/local/spark`. SSH 세션의 키체인 접근 불가로 Docker Hub pull 이 막혀 베이스 `ubuntu:latest` 를 `public.ecr.aws/docker/library/ubuntu` 에서 받아 태그(환경 우회, 테스트 코드 무변경)
    - 결과: #1~#6 jm4 exit 0, #7 jma pass=3 fail=0 — 재생목록 7/7 ✅
* 커밋: a12e091

## Issue17: TDD 재생목록 #1 compose-config-valid 구현 (등록: 2026-09-27, 해결: 2026-09-27) ✅
* 목적: `tdd/playlist.md` 1번 목표 — git 추적 compose 파일 전부에서 `docker compose config` 가 오류 없이 통과함을 테스트로 고정
* 상세:
    - 테스트 신설: `tdd/cases/compose-config-valid.sh` (git 추적 compose 12개 대상, `.history`·`_doc_*` 템플릿 제외)
    - red: `n8n/docker-compose.yml` 1건 실패 — `env_file: .env` 가 필수라 `.env`(gitignore, `start.sh` 가 생성) 없는 clean checkout 에서 config 불가
* 구현 명세:
    - `n8n` 의 `env_file` 을 `path: .env` + `required: false` 로 선택화. `.env` 존재 시 로드 동작은 동일함을 임시 복사본으로 확인
    - green: pass=12 fail=0. 재생목록 #1 실행 열·상태 ✅ 갱신
* 커밋: e25605b

## Issue16: _doc_arch ↔ 소스코드 정합성 감사 (해결: 2026-07-21) ✅
* 목적: `_doc_arch/` 영속 설계 문서의 참조 경로·스크립트명·동작 서술이 현재 소스코드와 어긋난 곳(stale)을 전수 검토·교정
* plan: `_doc_work/z_done/plan/doc-arch-source-audit_plan.md`
* task: `_doc_work/z_done/tasks/doc-arch-source-audit_task.md`
* 해결 결과: 대상 8개 문서 전수 대조 → 불일치 **11건** 교정
    - **폐기 설계 잔존(축4)**: `docker-run/design.md` 의 `nginx2` → `nginx_k8s` rename 반영. Issue14 로 이미 제거된 `mysql/start.sh`·`ubuntu_all/start.sh` FIXME 를 미해결 항목에서 해소 이력으로 이동(Issue14·Issue15 이력 신설)
    - **동작 서술 불일치(축3)**: `install.sh`(run)·`.env.sample`(compose) 의 "필수 ✅" 를 **조건부 필수**로 강등하고 판정 기준·현재 보유/미보유 폴더를 명시. 베이스 이미지 규정에 공식 이미지 케이스(`FROM nginx:1.30.3`) 추가 및 무태그 `FROM ubuntu` 금지 명문화
    - **정규화 범위 과장 교정**: "`docker compose`(v2) 전 스크립트 정규화" → 실행 스크립트 한정임을 명시. README 6종 v1 잔존을 `🔧 [FIXME]` 등재
    - **과거 기록 문서(축2)**: `known-issues-resolution.md` 상단에 현행 표준 안내 blockquote 추가(`.env.example`→`.env.sample`, `build-all.sh`→`start.sh`) — 당시 서술은 보존
    - **참조 대상 부재(축1)**: `project-purpose.md`·`patterns/README.md` 가 참조하던 루트 `README.md` "포트 사용 현황" 표가 실제로는 `CLAUDE.md` 에만 존재 → 참조처 교정 + 인수인계 관점 `🔧 [FIXME]` 등재
    - **감사 중 신규 발견**: `ubuntu_spark/README.md`·`CLAUDE.md` 가 구 버전 `spark-2.2.0-bin-hadoop2.7.tgz` 를 안내하나 `install.sh:58` 은 `3.4.4` 요구 → 안내대로 받으면 빌드 실패. `known-issues-resolution.md` 에 `🔧 [FIXME]` 등재. `ubuntu_ssh_provisioner/start.sh` 가 `${DF_PATH}` 미공급 상태로 compose 호출하는 결함도 함께 등재
    - 사후 검증: `_doc_arch/` 참조 경로 재-grep 완료. 잔여 MISS 는 전부 과거 이력 서술(`build-all.sh`, `docker-compose.yaml`)로 의도된 기록임을 확인
    - 미해결 마커 총 10건 부착 (`🚧 [TODO]` 1 · `🔧 [FIXME]` 7 · `🗑️ [REMOVE]` 2)
* commit: **없음** — `_doc_arch/`·`_doc_work/` 가 본 repo `.gitignore` 대상(9행·8행)이라 커밋 불가. remote 가 public(`git@github.com:Finfra/dockers.git`)이므로 `.gitignore` 수정·`git add -f` 강제 추적은 금지 사항이라 수행하지 않음. 본 이슈 항목(`Issue.md`)만 추적 대상
* 후속: gitignore 정책 자체의 재검토 필요성은 아래 `🌱 이슈후보` 에 등록 (본 작업 범위 밖)
* 참고: prj1#Issue307 fan-out 의 일부. 방법론 원본 prj1#Issue306

## Issue15: nginx·nginx2 이미지 nginx 버전 점검·보안 업데이트 (해결: 2026-07-16) ✅
* 배경: 2026-07 기준 nginx stable `1.30.3` / mainline `1.31.2`. `1.27` 이하는 EOL — 2026년 보안 픽스(CVE-2026-42530 HTTP/3 UAF, CVE-2026-42945 "NGINX Rift" 등) 미수혜
* 대상: `nginx/`·`nginx2/` — `FROM ubuntu`(무태그) + `install.sh` 의 apt nginx 라 배포판 버전에 종속·무핀 상태
* 해결 결과: `FROM ubuntu` → Docker Hub 공식 `FROM nginx:1.30.3` 로 교체(이미지명 변경만으로 해결). apt nginx 설치 불필요해져 `install.sh` 삭제. 빌드+컨테이너 실행+`nginx -v`+curl 검증 통과 (양쪽 `nginx/1.30.3` 확인)
* commit: 15ce829

## Issue14: 잔여 표준화 (start.sh CMD 정리) (해결: 2026-06-27) ✅
* depends: Issue9
* 해결 결과: dead `mysql/start.sh`·`ubuntu_all/start.sh` 제거, `ubuntu_all` CMD `["bash"]` 인라인화. README 핵심 섹션 순서는 기존 준수 확인(확장 섹션 보존)
* commit: 7a86046 (삭제분은 75ea3aa 에 동반)

## Issue13: springBoot_gradle 포트 충돌 (8080→8081) (해결: 2026-06-27) ✅
* depends: Issue9
* 해결 결과: host 포트 8081:8080. config 검증 통과
* commit: a263040

## Issue12: wordpress_adv·_ssl 포트 충돌 분리 (해결: 2026-06-27) ✅
* depends: Issue9
* 해결 결과: wordpress_adv 8083, wordpress_adv_ssl 8084 + DB 3308. `.env.sample` 추가, config 통과
* commit: 84bfc9c (install.sh→start.sh rename 은 75ea3aa)

## Issue11: pyspark-notebook 빌드 실패 수정 (해결: 2026-06-27) ✅
* depends: Issue9
* 해결 결과: 공식 `quay.io/jupyter/pyspark-notebook` base 로 교체(Spark·JDK 내장). 빌드 통과, SPARK_HOME 정상
* commit: 4e36ca8

## Issue10: ubuntu_user 빌드 실패 수정 (해결: 2026-06-27) ✅
* depends: Issue9
* 해결 결과: `python3.10`→`python3`+`python3-pip`, symlink 유지. 빌드 통과
* commit: 5fd2f56

## Issue9: 서비스 폴더 run/compose 패턴 표준화 (해결: 2026-06-27) ✅
* plan: `_doc_work/z_done/plan/docker-pattern-standardization_plan.md`
* task: `_doc_work/z_done/tasks/docker-pattern-standardization_task.md`
* 해결 결과: run 12종 `run.sh`, compose 11종 `start.sh`/`clear.sh`/`.env.sample`, `docker compose`(v2) 정규화, 중첩형 3종 래퍼, README 표준 블록. 런타임 검증 — compose config 11/11, run.sh 빌드 10/12(실패 2종은 Issue10·11 로 분리), clear.sh 환원 확인. 설계 SSOT `_doc_arch/patterns/`(로컬, gitignore)
* commit: 75ea3aa

## Issue8: 포트 충돌 위험 (해결: 2024-08-04) ✅
* 목적: 8080 포트 다중 서비스 충돌 방지
* 해결 결과: CLAUDE.md "포트 사용 현황 및 충돌 방지" 섹션 추가, 대안 포트(8081~8084) 정리

## Issue7: ollamaWebui 권한 문제 (해결: 2024-08-04) ✅
* 목적: 볼륨 권한 오류 해결
* 해결 결과: 권한 설정·SELinux·Docker 그룹·디버깅 가이드 추가

## Issue6: 환경 변수 파일 누락 (해결: 2024-08-04) ✅
* 목적: 필수 서비스 .env 가이드 제공
* 해결 결과: wordpress_adv·wordpress_adv_ssl `.env.example` 생성

## Issue5: Docker Buildx 호환성 (해결: 2024-08-04) ✅
* 목적: buildx 의존 제거
* 해결 결과: 전 서비스 표준 `docker build` 사용 확인

## Issue4: springBoot_gradle 종속성 이미지 (해결: 2024-08-04) ✅
* 목적: JDK17 의존 자동화
* 해결 결과: `build-all.sh` 전체 빌드 자동화 스크립트 추가

## Issue3: apacheSsl SSL 인증서 사전 생성 (해결: 2024-08-04) ✅
* 목적: 인증서 생성 편의성 개선
* 해결 결과: `generate-ssl.sh` 원클릭 인증서 생성 스크립트 추가

## Issue2: jdk17 빌드 명령어 구문 (해결: 2024-08-04) ✅
* 목적: 표준 빌드 명령어 확인
* 해결 결과: `docker build --rm -t nowage/jdk:17 .` 정상 확인

## Issue1: ubuntu_spark 필수 파일 누락 (해결: 2024-08-04) ✅
* 목적: Spark 바이너리 누락 해결
* 해결 결과: `spark-3.4.4-bin-hadoop3.tgz` 업그레이드, install.sh 수정

# ⏸️ 보류

# 🚫 취소

# 📜 참고
