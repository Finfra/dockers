#!/bin/bash

# n8n API 엔드포인트
N8N_API="http://localhost:5678/api/v1"

# API 키 설정
API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmOTVhN2ZjMS03NzM4LTRjOTgtYmJlMy02NWI5YzBkZDYzYjEiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzQ2MDI1NTU3LCJleHAiOjE3NDg1Nzc2MDB9.mgCMVQ8mMjXaCx-lB-kNU7-RYzaxL3UecD5eWK3i9Hc"

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
echo "POST 요청 응답:"
echo "$WORKFLOW_RESPONSE" | jq '.' 