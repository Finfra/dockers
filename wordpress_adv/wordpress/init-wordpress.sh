#!/bin/bash
set -e

# WordPress CLI 경로 설정
export PATH=$PATH:/usr/local/bin

# 환경 변수 로드 (주석 제외)
if [ -f /data/init/.env ]; then
    export $(grep -v '^#' /data/init/.env | xargs)
fi

# 디렉토리 권한 설정
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# WordPress 코어 다운로드
echo "WordPress 코어를 다운로드합니다..."
rm -rf /var/www/html/*
wp core download --path=/var/www/html --locale=ko_KR --force --allow-root

# wp-config.php 생성
wp config create --path=/var/www/html \
    --dbname=${WORDPRESS_DB_NAME} \
    --dbuser=${WORDPRESS_DB_USER} \
    --dbpass=${WORDPRESS_DB_PASSWORD} \
    --dbhost=${WORDPRESS_DB_HOST} \
    --allow-root

# WordPress 설치
wp core install --path=/var/www/html \
    --url=${WORDPRESS_URL} \
    --title="${WORDPRESS_TITLE:-"My Site"}" \
    --admin_user=${WORDPRESS_ADMIN_USER} \
    --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
    --admin_email=${WORDPRESS_ADMIN_EMAIL} \
    --skip-email \
    --allow-root

# WordPress URL 설정을 직접 데이터베이스에 업데이트
wp option update home "${WORDPRESS_URL}" --path=/var/www/html --allow-root
wp option update siteurl "${WORDPRESS_URL}" --path=/var/www/html --allow-root

# wp-config.php에 직접 URL 상수 추가
wp config set WP_HOME "${WORDPRESS_URL}" --path=/var/www/html --allow-root --type=constant
wp config set WP_SITEURL "${WORDPRESS_URL}" --path=/var/www/html --allow-root --type=constant

# 한국어 언어팩 설치
wp language core install ko_KR --path=/var/www/html --allow-root
wp language core activate ko_KR --path=/var/www/html --allow-root

# 기본 테마 설치 및 활성화
wp theme install twentytwentyfour --path=/var/www/html --allow-root
wp theme activate twentytwentyfour --path=/var/www/html --allow-root

# 기본 플러그인 설치 및 활성화
wp plugin install akismet --path=/var/www/html --allow-root
wp plugin activate akismet --path=/var/www/html --allow-root
# wp plugin install wordpress-seo --path=/var/www/html --allow-root
# wp plugin activate wordpress-seo --path=/var/www/html --allow-root

# 설치 완료 표시
touch /data/init/setting.ok
echo "WordPress 설치가 완료되었습니다."
