# Prepare
```
cd ../jdk17
docker build -t nowage/jdk:17 .
docker images|grep nowage/jdk
cd ../springBoot_gradle
./do.sh
sleep 2
curl 127.0.0.1:8080
```