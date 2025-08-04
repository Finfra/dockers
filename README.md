# Finfra/dockers - 소개

이 Git 저장소는 프로젝트에서 사용하는 Docker 스크립트 모음입니다.

## Docker 스크립트 목록

### 웹 서비스
|이름|설명|
|---|---|
|[nginx](./nginx)|Ubuntu 기반 Nginx 웹 서버|
|[nginx2](./nginx2)|Kubernetes용 Nginx 웹 서버|
|[apacheSsl](./apacheSsl)|SSL 인증서를 사용한 Apache 웹 서버 테스트|

### WordPress
|이름|설명|
|---|---|
|[wordpress](./wordpress)|기본 WordPress 설정|
|[wordpress_adv](./wordpress_adv)|HTTPS 및 한국어 지원이 포함된 고급 WordPress 설정|
|[wordpress_adv_ssl](./wordpress_adv_ssl)|SSL 인증서가 포함된 고급 WordPress 설정|

### 개발 환경
|이름|설명|
|---|---|
|[centos7_user](./centos7_user)|CentOS7 기반 사용자 생성 기능 포함|
|[ubuntu_basic](./ubuntu_basic)|Ubuntu 기본 이미지|
|[ubuntu_user](./ubuntu_user)|Ubuntu 기반 사용자 생성 기능 포함|
|[ubuntu_all](./ubuntu_all)|Ubuntu 종합 개발 환경|
|[ubuntu_ssh](./ubuntu_ssh)|SSH 접속이 가능한 Ubuntu 환경|
|[ubuntu_ssh_provisioner](./ubuntu_ssh_provisioner)|프로비저닝 기능이 포함된 Ubuntu SSH 환경|
|[oracle-linux_ssh](./oracle-linux_ssh)|SSH 접속이 가능한 Oracle Linux 환경|

### 데이터베이스
|이름|설명|
|---|---|
|[mysql](./mysql)|Python2/3가 추가된 MySQL|

### Java 개발
|이름|설명|
|---|---|
|[jdk17](./jdk17)|JDK 17 개발 환경|
|[springBoot_gradle](./springBoot_gradle)|Spring Boot + Gradle 개발 환경|

### 데이터 사이언스 & AI
|이름|설명|
|---|---|
|[pyspark-notebook](./pyspark-notebook)|Jupyter PySpark Notebook|
|[pyspark-tensorflow-notebook](./pyspark-tensorflow-notebook)|PySpark + TensorFlow Notebook|
|[tensorflow](./tensorflow)|TensorFlow 개발 환경|
|[ubuntu_spark](./ubuntu_spark)|Ubuntu 기반 Spark 환경|

### 자동화 도구
|이름|설명|
|---|---|
|[n8n](./n8n)|워크플로우 자동화 도구|
|[ollamaWebui](./ollamaWebui)|Ollama와 Open WebUI를 통한 AI 인터페이스|



## 일반적인 사용법

각 디렉토리에는 해당 서비스의 상세한 README.md 파일이 있습니다. 일반적인 패턴은 다음과 같습니다:

### 빌드
```bash
docker build --rm -t [이미지명] .
```

### 실행
```bash
docker run -it --name [컨테이너명] [옵션] [이미지명]
```

### 정리
```bash
docker rm [컨테이너명] -f
docker rmi [이미지명]
```

## 버그 리포트

버그는 nowage[at]gmail.com으로 신고해 주세요.

## 기여하기

GitHub 저장소: https://github.com/Finfra/dockers

## 작성자

NamJungGu, <nowage[at]gmail.com>

## 저작권 및 라이선스

(c) Copyright 2005-2024 by finfra.com
