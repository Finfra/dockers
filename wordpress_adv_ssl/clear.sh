#!/bin/bash

# 스크립트가 실패하면 즉시 종료
set -e

# 현재 디렉토리 저장
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Stopping and removing Docker containers and volumes..."
docker-compose --env-file .env down --volumes 2>/dev/null || true

# Docker 이미지 제거는 TLS 오류 발생 가능성으로 인해 생략
# 대신 로컬 이미지만 정리
echo "로컬 Docker 이미지 정리 중..."
docker image prune -f

echo "Clearing all data directories..."
mkdir -p data/contents data/secrets data/init data/wpDb1
rm -rf data/contents/* data/secrets/* data/init/* data/wpDb1/* .env

# setting.ok 파일 삭제
rm -f data/contents/setting.ok

echo "All data directories have been cleared."
echo "모든 데이터가 삭제되었습니다." 