#!/bin/bash

# n8n API 엔드포인트
N8N_API="http://localhost:5678/api/v1"

# API 키 설정
API_KEY_FILE="n8n/data/setting/api_key"
if [ ! -f "$API_KEY_FILE" ]; then
    echo "API 키 파일이 존재하지 않습니다."
    echo "n8n 웹 인터페이스에서 API 키를 생성하고 입력해주세요."
    echo "API 키는 n8n 웹 인터페이스의 Settings > API에서 확인할 수 있습니다."
    read -p "API 키를 입력하세요: " API_KEY
    echo "$API_KEY" > "$API_KEY_FILE"
    echo "API 키가 파일에 저장되었습니다."
else
    API_KEY=$(cat "$API_KEY_FILE")
fi

echo "Using API Key: $API_KEY"

# SQLite를 사용하여 워크플로우 삭제
echo "SQLite에서 워크플로우 삭제 중..."
cd n8n/data/setting && sqlite3 database.sqlite "DELETE FROM workflow_entity WHERE name='w1';"

echo "Waiting for 5 seconds..."
sleep 5

# 새 워크플로우 가져오기
echo "새 워크플로우 가져오는 중..."
cd ../.. && WORKFLOW_RESPONSE=$(curl -s -X POST "$N8N_API/workflows" \
  -H "X-N8N-API-KEY: $API_KEY" \
  -H "Content-Type: application/json" \
  -d @w1.json)

echo "워크플로우 응답: $WORKFLOW_RESPONSE"

# 워크플로우 ID 추출 (jq 사용)
WORKFLOW_ID=$(echo "$WORKFLOW_RESPONSE" | jq -r '.id')
echo "워크플로우 ID: $WORKFLOW_ID"

if [ -z "$WORKFLOW_ID" ]; then
  echo "워크플로우 ID를 찾을 수 없습니다."
  exit 1
fi

# 워크플로우 활성화
echo "워크플로우 활성화 중..."
ACTIVATE_RESPONSE=$(curl -s -X POST "$N8N_API/workflows/$WORKFLOW_ID/activate" \
  -H "X-N8N-API-KEY: $API_KEY" \
  -H "Content-Type: application/json")

echo "활성화 응답: $ACTIVATE_RESPONSE"
echo "워크플로우 가져오기 및 활성화 완료"

# POST 요청 응답 출력
echo "POST 요청 응답:  curl -X POST "http://localhost:5678/webhook/webhook1" -H "Content-Type: application/json" -d '{"test": "data3"}'"