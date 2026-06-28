# Finfra/dockers - Docker 컨테이너 스크립트 모음집

이 프로젝트는 다양한 웹 서비스, 개발 환경, 데이터베이스, 데이터 사이언스 도구들을 Docker로 구성하여 빠른 개발 환경 구축을 지원하는 Docker 컨테이너 스크립트 모음

## 🚀 주요 특징

- **자동화된 환경 구축**: 각 서비스별 자동 설치 스크립트 제공
- **표준화된 문서**: 모든 서비스의 일관된 한국어 문서 제공
- **보안 강화**: SSL 인증서 자동 생성 및 관리
- **의존성 관리**: 서비스 간 의존성 자동 처리
- **포트 충돌 방지**: 각 서비스별 고유 포트 할당

## Docker 스크립트 목록

### 웹 서비스
| 이름                     | 설명                                      |
| ------------------------ | ----------------------------------------- |
| [nginx](./nginx)         | Ubuntu 기반 Nginx 웹 서버                 |
| [nginx2](./nginx2)       | Kubernetes용 Nginx 웹 서버                |
| [apacheSsl](./apacheSsl) | SSL 인증서를 사용한 Apache 웹 서버 테스트 |

### WordPress
| 이름                                     | 설명                                              |
| ---------------------------------------- | ------------------------------------------------- |
| [wordpress](./wordpress)                 | 기본 WordPress 설정                               |
| [wordpress_adv](./wordpress_adv)         | HTTPS 및 한국어 지원이 포함된 고급 WordPress 설정 |
| [wordpress_adv_ssl](./wordpress_adv_ssl) | SSL 인증서가 포함된 고급 WordPress 설정           |

### 개발 환경
| 이름                                               | 설명                                     |
| -------------------------------------------------- | ---------------------------------------- |
| [centos7_user](./centos7_user)                     | CentOS7 기반 사용자 생성 기능 포함       |
| [ubuntu_basic](./ubuntu_basic)                     | Ubuntu 기본 이미지                       |
| [ubuntu_user](./ubuntu_user)                       | Ubuntu 기반 사용자 생성 기능 포함        |
| [ubuntu_all](./ubuntu_all)                         | Ubuntu 종합 개발 환경                    |
| [ubuntu_ssh](./ubuntu_ssh)                         | SSH 접속이 가능한 Ubuntu 환경            |
| [ubuntu_ssh_provisioner](./ubuntu_ssh_provisioner) | 프로비저닝 기능이 포함된 Ubuntu SSH 환경 |
| [oracle-linux_ssh](./oracle-linux_ssh)             | SSH 접속이 가능한 Oracle Linux 환경      |

### 데이터베이스
| 이름             | 설명                     |
| ---------------- | ------------------------ |
| [mysql](./mysql) | Python2/3가 추가된 MySQL |

### Java 개발
| 이름                                     | 설명                           |
| ---------------------------------------- | ------------------------------ |
| [jdk17](./jdk17)                         | JDK 17 개발 환경               |
| [springBoot_gradle](./springBoot_gradle) | Spring Boot + Gradle 개발 환경 |

### 데이터 사이언스 & AI
| 이름                                                         | 설명                          |
| ------------------------------------------------------------ | ----------------------------- |
| [pyspark-notebook](./pyspark-notebook)                       | Jupyter PySpark Notebook      |
| [pyspark-tensorflow-notebook](./pyspark-tensorflow-notebook) | PySpark + TensorFlow Notebook |
| [tensorflow](./tensorflow)                                   | TensorFlow 개발 환경          |
| [ubuntu_spark](./ubuntu_spark)                               | Ubuntu 기반 Spark 환경        |

### LLM관련 도구
| 이름                         | 설명                                     |
| ---------------------------- | ---------------------------------------- |
| [n8n](./n8n)                 | 워크플로우 자동화 도구                   |
| [ollamaWebui](./ollamaWebui) | Ollama와 Open WebUI를 통한 AI 인터페이스 |



## 🛠️ 일반적인 사용법

각 디렉토리에는 해당 서비스의 상세한 README.md 파일이 있습니다. 

### 기본 패턴
```bash
# 1. 서비스 디렉토리로 이동
cd [서비스명]/

# 2. Docker 이미지 빌드
docker build --rm -t [이미지명] .

# 3. 컨테이너 실행
docker run -it --name [컨테이너명] [포트옵션] [이미지명]

# 4. 서비스 테스트
curl localhost:[포트번호]

# 5. 정리
docker rm [컨테이너명] -f
docker rmi [이미지명]
```

### 표준 스크립트 (패턴별)
모든 서비스는 2종 폴더 패턴 중 하나를 따릅니다 (설계: `_doc_arch/patterns/`).

```bash
# docker-run 패턴 (단일 이미지: nginx, mysql, ubuntu_* 등)
./run.sh          # build + run + test 래퍼

# docker-compose 패턴 (다중 컨테이너: n8n, wordpress_adv, ollamaWebui 등)
./start.sh        # env 생성 + build + up -d + 헬스체크
./clear.sh        # down --volumes + data 정리
```

> 신규 서비스는 `_doc_arch/patterns/{docker-run|docker-compose}/template/` 를 복사해 시작합니다.

## ⚠️ 특별한 요구사항

### Spring Boot Gradle
JDK 17 이미지가 먼저 빌드되어야 합니다:
```bash
cd jdk17 && docker build -t nowage/jdk:17 .
cd ../springBoot_gradle && ./start.sh
```

### Ubuntu Spark
Spark와 Hadoop 바이너리 파일을 수동으로 다운로드해야 합니다:
```bash
cd ubuntu_spark/_prgs/
# Apache Spark 다운로드
wget https://archive.apache.org/dist/spark/spark-3.4.4/spark-3.4.4-bin-hadoop3.tgz

# Apache Hadoop 다운로드 
wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
```

**참고**: 이 파일들은 용량이 커서 git 저장소에 포함되지 않습니다.

### SSL 인증서 (apacheSsl, wordpress_adv_ssl)
SSL 인증서 생성:
```bash
./apacheSsl/generate-ssl.sh  # 자동 생성 (권장)
```

## 🔧 문제 해결

자세한 문제 해결 방법은 각 서비스의 README.md 파일과 Issue.md 파일을 참조하세요.

## 버그 리포트

버그는 nowage[at]gmail.com으로 신고해 주세요.

## 기여하기

GitHub 저장소: https://github.com/Finfra/dockers

## 작성자

NamJungGu, <nowage[at]gmail.com>

## 저작권 및 라이선스

(c) Copyright 2005-2024 by finfra.com
