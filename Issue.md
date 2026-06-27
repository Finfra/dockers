---
title: dockers Issue
description: dockers 프로젝트 이슈 관리 파일 (내부 개발자용-public 이슈는 github이슈 사용)
date: 2026-06-26
---

# Issue Management
* Issue HWM: 14
* 설계·해결 기록: `_doc_arch/known-issues-resolution.md` (구 Issue.md, 2024-08 8/8 해결 완료)
* Save Point:
    - {git-hash} {date}

# 🤔 결정사항

# 🌱 이슈후보

# 🚧 진행중

# 📕 중요

# 📙 일반

# 📗 선택

# ✅ 완료

> 상세 해결 내역은 `_doc_arch/known-issues-resolution.md` 참조.

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
* plan: `_doc_work/plan/docker-pattern-standardization_plan.md`
* task: `_doc_work/tasks/docker-pattern-standardization_task.md`
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
