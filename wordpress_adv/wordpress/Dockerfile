FROM wordpress:latest

# WP-CLI 설치
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# 설치 스크립트 복사
COPY init-wordpress.sh /usr/local/bin/init-wordpress.sh
RUN chmod +x /usr/local/bin/init-wordpress.sh

# 진입점 스크립트 복사
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# .env 파일을 위한 디렉토리 생성
RUN mkdir -p /data/init

# .env 파일 복사
COPY ../.env /data/init/.env

# 진입점 스크립트 실행
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
