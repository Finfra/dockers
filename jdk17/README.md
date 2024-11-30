
# Build & Test
```
#docker build -t nowage/jdk:8.0 .
docker build -t nowage/jdk:17 .
#docker build -t nowage/jdk:21 .
docker run -it --name j1 --rm -v ./../app:/app nowage/jdk:17
``` 