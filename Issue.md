---
title: dockers Issue
description: dockers 프로젝트 이슈 관리 파일 (내부 개발자용-public 이슈는 github이슈 사용)
date: 2026-06-26
---

# Issue Management
* Issue HWM: 17
* 설계·해결 기록: `_doc_arch/known-issues-resolution.md` (구 Issue.md, 2024-08 8/8 해결 완료)
* Checkpoints:
    - {git-hash} {date}

# 🤔 결정사항

# 🌱 이슈후보

1. `_doc_arch`/`_doc_work` gitignore 정책 재검토 — 설계 SSOT 변경이 커밋 이력에 남지 않아 이슈 종결 시 commit hash 를 만들 수 없음(Issue16 에서 실제 발생). remote 가 public 이라 단순 추적 전환은 불가 → 별도 private repo 분리·submodule·mirror 등 대안 검토 필요
2. `ubuntu_spark/README.md`·`CLAUDE.md` 의 Spark 버전 안내를 `install.sh` 기준 `3.4.4` 로 통일 (현재 `2.2.0` 안내대로 받으면 빌드 실패)
3. `springBoot_gradle/do.sh`·`wordpress_adv_ssl/install.sh` 정리 + `wordpress_adv`/`wordpress_adv_ssl` 의 구 `.env.example` 제거
4. 폴더 README 6종의 `docker-compose`(v1) 표기를 `docker compose`(v2) 로 정규화
5. `ubuntu_ssh_provisioner/start.sh` 가 `DF_PATH` 를 공급하도록 수정 (`.env.sample` 추가 또는 `docker/docker-compose.sh` 로 위임)

# 🚧 진행중

# 📕 중요

# 📙 일반

# 📗 선택

# ✅ 완료

> 상세 해결 내역은 `_doc_arch/known-issues-resolution.md` 참조.

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
