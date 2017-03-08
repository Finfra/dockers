# dockerfiles-centos-user-adderable
Centos7, It support base user creation and password setting.

# Building & Running

Copy the sources to your docker host and build the container, and to run.
```
	docker build --rm -t nowage/centos7 .
	docker run -it --name c1 -e USER=nowage -e PASSWD=nowage nowage/centos7
```
Get the port that the container is listening on:

```
# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
ad2ad96e4b2f        nowage/centos7      "/bin/bash"         7 seconds ago       Up 6 seconds                            c1
```

To test, ("nowage" is username. )
```
	su - nowage
```
To Rollback
```
    docker rm c1 -f
    docker rmi nowage/centos7
```
