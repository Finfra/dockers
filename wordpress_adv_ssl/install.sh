#!/bin/bash

# 스크립트가 실패하면 즉시 종료
set -e

# 현재 디렉토리 저장
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"



# 기존 컨테이너와 볼륨 정리
echo "Cleaning up existing containers and volumes..."
docker-compose --env-file .env down --volumes || true

# clear 옵션 처리
if [ "$1" == "--clear" ]; then
    echo "Cleaning up existing containers and volumes..."
    ./clear.sh
    echo "Data cleared. Continuing with installation..."
fi

# 비밀번호 파일에서 비밀번호 읽기, 없으면 입력받기
if [ ! -f ~/.ssh/basic_pw ]; then
    read -p "Enter the basic password: " BASIC_PW
    echo "$BASIC_PW" > ~/.ssh/basic_pw
else
    BASIC_PW=$(cat ~/.ssh/basic_pw)
fi

# setting.ok 파일 존재 여부 확인
if [ ! -f "data/init/setting.ok" ]; then
    echo "setting.ok 파일이 없습니다. 초기 설정을 진행합니다..."

# .env 파일 생성
echo "Creating .env file..."
cat > .env << EOF
# MySQL 설정
DB_ROOT_PASSWORD=${BASIC_PW}
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=${BASIC_PW}

# WordPress 설정
WORDPRESS_DB_HOST=wpdb1
WORDPRESS_DB_USER=wordpress
WORDPRESS_DB_PASSWORD=${BASIC_PW}
WORDPRESS_DB_NAME=wordpress
WORDPRESS_TITLE="MySite"
WORDPRESS_ADMIN_USER=admin
WORDPRESS_ADMIN_PASSWORD=${BASIC_PW}
WORDPRESS_ADMIN_EMAIL=jgnam73@hotmail.com
WORDPRESS_URL=http://localhost:8080
EOF
    # .env 파일 복사 wordpress 폴더에 복사
    cp .env wordpress/
    # 필요한 디렉토리 생성
    echo "Creating necessary directories..."
    mkdir -p data/contents data/init data/wpDb1

    # WordPress 설정 파일 복사
    echo "Copying wp-config.php..."
    cp wp-config.php data/contents/

    # .env 파일을 data/init으로 복사
    echo "Copying .env file to data/init..."
    cp .env data/init/

    # x64 환경인 경우 docker-compose.yml 수정
    if [ "$(uname -m)" = "x86_64" ]; then
        sed -i '' 's/platform: linux\/arm64\/v8//g' docker-compose.yml
    fi

    # 초기화 스크립트 복사
    echo "초기화 스크립트를 복사합니다..."
    cp wordpress/docker-entrypoint.sh data/init/
    cp wordpress/init-wordpress.sh data/init/
    cp .env data/init/
    chmod +x data/init/*.sh
    
    # Docker 이미지 빌드
    echo "Building Docker images..."
    docker-compose --env-file .env build
fi

# Docker Compose 실행
echo "Starting Docker containers..."
docker-compose --env-file .env up -d

# MySQL이 준비될 때까지 대기
echo "Waiting for MySQL to be ready..."
until docker-compose --env-file .env exec -T wpDb1 mysqladmin ping -h localhost -u root --password="${BASIC_PW}" --silent; do
    echo "MySQL is not ready yet. Waiting..."
    sleep 5
done
echo "MySQL is ready!"

# WordPress 컨테이너가 준비될 때까지 대기
echo "Waiting for WordPress to be ready..."
until curl -s http://localhost:8080 > /dev/null; do
    echo "WordPress is not ready yet. Waiting..."
    sleep 5
done

# 설치 완료 메시지
echo -e "\n\033[1;32mWordPress installation is complete!\033[0m\n"

# 실행 중인 컨테이너 목록 표시
echo -e "\033[1;34mRunning Containers:\033[0m"
docker-compose --env-file .env ps

# 접속 정보 표시
echo -e "\n\033[1;34mWordPress Access Information:\033[0m"
echo "URL: http://localhost:8080"
echo "Admin URL: http://localhost:8080/wp-admin"
echo "Admin Username: admin"
echo "Admin Password: ${BASIC_PW}"
echo ""
echo -e "\033[1;34mDatabase Information:\033[0m"
echo "Host: wpdb1"
echo "Database: wordpress"
echo "Username: wordpress"
echo "Password: ${BASIC_PW}"
echo ""
echo -e "\033[1;34mManagement Commands:\033[0m"
echo "To stop containers: docker-compose --env-file .env down"
echo "To clear all data: ./clear.sh"
