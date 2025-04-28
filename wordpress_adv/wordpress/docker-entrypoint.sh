#!/bin/bash
set -e

# PHP 메모리 제한 설정
echo "memory_limit = 1024M" > /usr/local/etc/php/conf.d/memory-limit.ini

# WordPress CLI 경로 설정
export PATH=$PATH:/usr/local/bin

# 환경 변수 로드 (주석 제외)
if [ -f /data/init/.env ]; then
    export $(grep -v '^#' /data/init/.env | xargs)
fi

# 디렉토리 권한 설정
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# WordPress 초기화 스크립트 실행 (한 번만 실행)
if [ -f /data/init/init-wordpress.sh ] && [ ! -f /data/init/setting.ok ]; then
    echo "WordPress 초기화 스크립트를 실행합니다..."
    bash /data/init/init-wordpress.sh
fi

# Apache 설정 수정
echo "ServerName localhost" >> /etc/apache2/apache2.conf
a2enmod rewrite
a2enmod headers

# Apache 실행
echo "Apache를 시작합니다..."
exec apache2-foreground
