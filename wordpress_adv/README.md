# WordPress 고급 Docker 설정

이 프로젝트는 Docker를 사용하여 WordPress와 MySQL을 자동으로 프로비저닝하는 고급 설정을 제공합니다.

## 시스템 요구사항

- Docker
- Docker Compose
- ~/.ssh/basic_pw 파일 (비밀번호 저장용)

## 설치 및 실행 방법

1. 스크립트 실행 권한 부여:
```bash
chmod +x install.sh clear.sh
```

2. 설치 스크립트 실행:
```bash
./install.sh
```

3. 모든 데이터 초기화:
```bash
./clear.sh
```

## 주요 특징

- 자동화된 설치 프로세스
- 보안을 위한 Docker Secrets 사용
- 아키텍처 자동 감지 (ARM64/x64)
- 로컬 컨텐츠 디렉토리 매핑
- 기존 컨테이너 자동 정리
- 데이터 초기화 기능 (clear.sh)

## 디렉토리 구조

- `contents/`: WordPress 파일이 저장되는 디렉토리 (git에서 제외)
- `secrets/`: 데이터베이스 비밀번호가 저장되는 디렉토리
- `init/`: MySQL 초기화 스크립트를 위한 디렉토리
- `mysql/`: MySQL 데이터가 저장되는 디렉토리 (git에서 제외)

## 보안

- 데이터베이스 비밀번호는 Docker Secrets를 통해 관리
- 비밀번호는 ~/.ssh/basic_pw 파일에서 읽어옴
- secrets 디렉토리는 .gitignore에 포함됨

## 데이터 초기화

`clear.sh` 스크립트를 사용하여 모든 데이터를 초기화할 수 있습니다:
```bash
./clear.sh
```
이 명령은 다음 디렉토리의 모든 내용을 삭제합니다:
- contents/
- secrets/
- init/
- mysql/

## 컨테이너 중지

```bash
docker-compose down
```

## 볼륨 삭제

```bash
docker-compose down -v
``` 