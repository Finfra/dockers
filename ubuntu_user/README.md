# dockerfiles-ubuntu-user-adderable
Ubuntu, It support base user creation and password setting.

# Building & Running

Copy the sources to your docker host and build the container, and to run.
```
	docker build --rm -t nowage/ubuntu .
	docker run -it --name u1 -e USER=nowage -e PASSWD=nowage nowage/ubuntu
```
Get the port that the container is listening on:

```
# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
ad2ad96e4b2f        nowage/ubuntu      "/bin/bash"         7 seconds ago       Up 6 seconds                            u1
```

To test, ("nowage" is username. )
```
	su - nowage
```
To Rollback
```
    docker rm u1 -f
    docker rmi nowage/ubuntu
```
