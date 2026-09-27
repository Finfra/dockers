---
title: dockers TDD 재생목록
description: prj71 dockers 의 TDD 목표를 재생 순서로 나열한 목록 (prj6#Issue16)
date: 2026.09.26
---

# 무엇을 지키나

각 Docker 예제 폴더가 표준 패턴을 지키고 포트 충돌 없이 설정 검증·빌드가 통과함을 지킨다

* 러너: 목표별 쉘 스크립트 `tdd/cases/<id>.sh` — 종료코드 0 = 통과
* 목표 7개 중 테스트로 덮인 것 1개 · 남은 신규 6개

# 재생목록

위에서 아래로 돈다 — 빠르고 기초적인 것이 먼저, 통합·E2E 가 뒤다. 앞 항목이 깨지면 뒤 항목의 실패는 원인이 아니라 결과일 수 있다.

| # | id | 목표 | 근거 | 실행 | 상태 |
| :- | :- | :- | :- | :- | :- |
| 1 | `compose-config-valid` | compose 형 폴더 전부에서 docker compose config 가 오류 없이 통과한다 | Issue9 run/compose 패턴 표준화 (런타임 검증 compose config); Issue12·Issue13 config 통과; Issue17 n8n `.env` 부재 시 실패 | [compose-config-valid.sh](cases/compose-config-valid.sh) | ✅ |
| 2 | `host-port-unique` | 전 compose 파일의 호스트 포트 매핑이 서로 겹치지 않는다(8080·8081·8083·8084·3308 등) | Issue8 포트 충돌 위험; Issue12 wordpress_adv 8083/_ssl 8084+DB 3308; Issue13 springBoot_gradle 8081 | — | ⬜ 신규 |
| 3 | `folder-pattern` | compose 폴더는 start.sh·clear.sh 를, run 폴더는 run.sh 를 가지며 제거된 build-all.sh·dead start.sh 가 남지 않는다 | Issue9 표준화(run 12종 run.sh, compose 11종 start.sh/clear.sh/.env.sample); Issue14 dead start.sh 제거 | — | ⬜ 신규 |
| 4 | `compose-v2-only` | 실행 스크립트에 docker-compose(v1) 호출이 없고 docker compose(v2)만 쓴다 | Issue9 docker compose(v2) 정규화; Issue16 README 6종 v1 잔존 FIXME | — | ⬜ 신규 |
| 5 | `nginx-pinned` | nginx Dockerfile 이 무태그 FROM 없이 nginx:1.30.3 으로 고정된다 | Issue15 nginx 버전 점검·보안 업데이트 (FROM ubuntu 무핀 → nginx:1.30.3) | — | ⬜ 신규 |
| 6 | `spark-version-doc-match` | ubuntu_spark README·CLAUDE.md 가 안내하는 Spark tgz 버전이 install.sh 요구 버전(3.4.4)과 일치한다 | Issue16 감사 중 신규 발견 — README 는 spark-2.2.0, install.sh:58 은 3.4.4 요구; Issue1 | — | ⬜ 신규 |
| 7 | `image-build-smoke` | 과거 빌드 실패 이미지(ubuntu_user·pyspark-notebook)가 docker build 에 성공하고 pyspark 컨테이너에 SPARK_HOME 이 설정된다 | Issue10 ubuntu_user 빌드 실패; Issue11 pyspark-notebook 빌드 실패 (SPARK_HOME 정상 확인) | — | ⬜ 신규 |

# 규약

* **목표는 «검증 가능한 성질»** 이다 — *"잘 동작한다"* 는 목표가 아니다
* 새 버그를 고치면 **재현 테스트를 먼저** 여기 한 줄로 올리고(⬜), 테스트가 생기면 실행 열을 채워 ✅ 로 바꾼다
* 실패를 삼키는 패턴(`2>/dev/null || true` 등)을 테스트 안에 쓰지 않는다 — 실패는 실패로 드러나야 한다
* 판정 출처: prj6 `_doc_work/report/tdd-coverage_report.md` (이 프로젝트가 왜 TDD 대상인가)
