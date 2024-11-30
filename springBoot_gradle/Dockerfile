FROM nowage/jdk:17

# 필수 패키지 설치
# RUN apt-get update && apt-get install -y zip curl

# SDKMAN! 및 Gradle 설치, 애플리케이션 빌드
RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
    sdk install gradle && \
    gradle -v && \
    mkdir /app"

# 작업 디렉토리 설정
WORKDIR /app

# 소스 코드 복사
# COPY ./app /app

# 애플리케이션 빌드 
RUN bash -c "cd /app&&source $HOME/.sdkman/bin/sdkman-init.sh && gradle build -x test&&java -jar /app/app-0.0.1-SNAPSHOT.jar"

# 빌드된 JAR 파일 실행
CMD ["java", "-jar", "/app/app-0.0.1-SNAPSHOT.jar"]

# # 디버깅용
#CMD ["/usr/bin/sleep", "infinity"]




