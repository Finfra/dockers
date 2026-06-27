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

## Issue9: 서비스 폴더 run/compose 패턴 표준화 (등록: 2026-06-26)
* 목적: 코워커가 README 만으로 컨테이너 생성·관리 가능하도록 폴더 패턴 2종(run/compose) 표준화. 프로젝트 목적(`_doc_arch/project-purpose.md`) 중 "인수인계" 달성의 전제
* plan: `_doc_work/plan/docker-pattern-standardization_plan.md`
* task: `_doc_work/tasks/docker-pattern-standardization_task.md`
* 상세:
    - 설계 SSOT: `_doc_arch/patterns/` (run/compose design.md + template/)
    - run 표준: `Dockerfile`+`install.sh`+`run.sh`+README, `docker build`/`docker run`
    - compose 표준: `docker-compose.yml`+`.env.sample`+`start.sh`+`clear.sh`+README, `docker compose`(v2)
    - 정렬 대상: compose 8종, run 12종, 미분류 3종(ubuntu_ssh·ubuntu_ssh_provisioner·oracle-linux_ssh)
* 구현 명세:
    - 표준화만 수행, 이미지 기능 변경 금지
    - 폴더별 독립 → 병렬·분할 커밋
    - 완료 조건: run 폴더 `./run.sh` 통과, compose 폴더 `./start.sh`→`./clear.sh` 왕복 통과

# 📕 중요

# 📙 일반

## Issue10: ubuntu_user 빌드 실패 (python3.10 패키지 부재) (등록: 2026-06-26)
* 목적: `apt install -y python3.10` exit 100 으로 빌드 실패 → ubuntu base 갱신으로 python3.10 패키지 부재
* depends: Issue9
* 상세:
    - 파일: `ubuntu_user/Dockerfile`
    - 증상: `process "/bin/sh -c apt install -y python3.10" did not complete successfully: exit code: 100`
    - 출처: Issue9 런타임 검증(`_doc_work/report/pattern-test-result.md`)
* 구현 명세: `python3.10` 고정 → `python3`(배포 기본) 또는 deadsnakes PPA 추가. symlink `python3`→`python` 유지

## Issue11: pyspark-notebook 빌드 실패 (EOL repo·죽은 URL) (등록: 2026-06-26)
* 목적: jessie-backports(EOL)·cloudfront Spark URL 사망으로 빌드 실패
* depends: Issue9
* 상세:
    - 파일: `pyspark-notebook/Dockerfile`
    - 증상: `jupyter/scipy-notebook` + Debian jessie-backports openjdk-8 설치 실패, `d3kbcqa49mib13.cloudfront.net` Spark 2.1.0 URL 사망
    - 출처: Issue9 런타임 검증
* 구현 명세: 공식 `jupyter/pyspark-notebook`(Spark 내장) base 로 교체 → 수동 Spark/Mesos 설치 제거

## Issue12: wordpress_adv·_ssl 포트 충돌 (8080/3307) (등록: 2026-06-26)
* 목적: host 포트 8080·3307 점유 충돌로 `up` 실패 (config 는 유효)
* depends: Issue9
* 상세:
    - 파일: `wordpress_adv/docker-compose.yml`, `wordpress_adv_ssl/docker-compose.yml`
    - 두 서비스가 동일 8080:80·3307:3306 사용 → 동시·기존 점유 시 충돌
    - 출처: Issue9 런타임 검증, CLAUDE.md "포트 충돌 방지"
* 구현 명세: CLAUDE.md 대안 포트 적용 — wordpress_adv 8083, wordpress_adv_ssl 8084, DB 포트 분리(3307/3308)

## Issue13: springBoot_gradle 포트 충돌 (8080) (등록: 2026-06-26)
* 목적: host 8080 점유 충돌로 `up` 실패 (config 유효)
* depends: Issue9
* 상세:
    - 파일: `springBoot_gradle/docker-compose.yml`
    - 출처: Issue9 런타임 검증
* 구현 명세: CLAUDE.md 대안 포트 8081:8080 적용

## Issue14: 잔여 표준화 (README 섹션 순서 + start.sh CMD 정리) (등록: 2026-06-26)
* 목적: Issue9 에서 별도 패스로 미룬 표준화 잔여 항목 마무리
* depends: Issue9
* arch: `_doc_arch/patterns/`
* 상세:
    - 폴더별 README 섹션 순서를 각 패턴 design.md 표준 순서로 통일
    - `mysql/start.sh`(`/bin/bash`), `ubuntu_all/start.sh`(`bash`) 의미 중복 CMD 정리
    - 출처: Issue9 design.md "미해결 항목" 🔧 마커
* 구현 명세: README 섹션 재배열(내용 보존), 불필요 start.sh 제거 또는 역할 명확화

# 📗 선택

# ✅ 완료

> 상세 해결 내역은 `_doc_arch/known-issues-resolution.md` 참조.

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
