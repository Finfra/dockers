FROM mysql:8.0

# MySQL 설정 파일 복사
COPY my.cnf /etc/mysql/conf.d/

# 포트 노출
EXPOSE 3306

# 데이터베이스 초기화 스크립트 실행
CMD ["mysqld"] 