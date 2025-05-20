#!/bin/bash

# 현재 스크립트가 위치한 디렉토리의 절대 경로 가져오기 (sourced 되어도 작동)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# .env 파일이 스크립트 디렉토리에 존재하면 로드
if [ -f "${SCRIPT_DIR}/.env" ]; then
    echo "환경변수 파일 로딩: ${SCRIPT_DIR}/.env"
    source "${SCRIPT_DIR}/.env"
else
    echo "환경변수 파일 없음: ${SCRIPT_DIR}/.env" >&2
fi

# DF_PATH 환경변수 확인 및 존재 여부 체크
if [ -z "${DF_PATH}" ]; then
    echo "오류: DF_PATH 환경변수가 설정되지 않음" >&2
    read -p "df 폴더가 정의되지 않았습니다. 경로를 입력하세요: " DF_PATH
elif [ ! -d "${DF_PATH}" ]; then
    echo "오류: DF_PATH='${DF_PATH}' 디렉토리가 존재하지 않음" >&2
    read -p "df 폴더가 없습니다. 경로를 다시 입력하세요: " DF_PATH
else
    echo "DF_PATH가 '${DF_PATH}'로 설정되어 있으며 디렉토리가 존재함"
fi

# 입력 받은 DF_PATH를 .env 파일에 저장 (매번 덮어씀)
echo DF_PATH=$DF_PATH > $SCRIPT_DIR/.env

# 작업 디렉토리 이동 및 docker-compose 실행
cd "$SCRIPT_DIR"
docker-compose up -d
