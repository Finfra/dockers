# dockerfiles-ubuntu-user-adderable-spark
Ubuntu, It support base user creation and password setting.

# Building & Running

Copy the sources to your docker host and build the container, and to run.
```
	docker build --rm -t nowage/spark .
	docker run -it --rm                 \
    --name s1                           \
    -e USER=nowage -e PASSWD=nowage     \
    -v ~/df:/df                         \
    -p 8081:8081                        \
    -p 8080:8080                        \
    -p 7077:7077                        \
    nowage/spark
```
Get the port that the container is listening on:

```
# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
ad2ad96e4b2f        nowage/spark      "/bin/bash"         7 seconds ago       Up 6 seconds                            s1
```

To test, ("nowage" is username. )
```
	su - nowage
```
To Rollback
```
    docker rm s1 -f
    docker rmi nowage/ubuntu
```

# Requirement 
Download spark-2.2.0-bin-hadoop2.7.tgz to _prgs folder.
