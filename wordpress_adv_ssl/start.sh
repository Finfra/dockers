#!/bin/bash

# 환경변수 로드
if [ -f .env ]; then
    set -a  # automatically export all variables
    source .env
    set +a
fi

# 컨테이너 정리
echo "Cleaning up existing containers..."
docker compose down

# 컨테이너 시작
echo "Starting Docker containers..."
docker compose up -d

# MySQL 준비 대기
echo "Waiting for MySQL to be ready..."
until docker exec wpDb1 mysqladmin ping -h localhost -u root -p${DB_ROOT_PASSWORD} --silent; do
    echo "Waiting for MySQL..."
    sleep 2
done
echo "MySQL is ready!"

# WordPress 준비 대기
echo "Waiting for WordPress to be ready..."
until curl -s -L -k http://localhost:8084 > /dev/null 2>&1; do
    echo "Waiting for WordPress..."
    sleep 2
done
echo "WordPress is ready!"

# 실행 중인 컨테이너 정보 출력
echo -e "\nRunning Containers:"
docker compose ps

# 접속 정보 출력
echo -e "\nWordPress Access Information:"
echo "URL: http://localhost:8084"
echo "HTTPS URL: https://localhost:8443"
echo "Admin URL: http://localhost:8084/wp-admin"
echo "Admin Username: ${WORDPRESS_ADMIN_USER}"
echo "Admin Password: ${WORDPRESS_ADMIN_PASSWORD}"

echo -e "\nDatabase Information:"
echo "Host: wpdb1"
echo "Database: ${DB_NAME}"
echo "Username: ${DB_USER}"
echo "Password: ${DB_PASSWORD}"

echo -e "\nManagement Commands:"
echo "To stop containers: docker compose --env-file .env down"
echo "To clear all data: ./clear.sh" 