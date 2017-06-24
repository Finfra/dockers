# dockerfiles-centos-user-adderable
pyspark notebook, It support base user creation and password setting.

# Building & Running

Copy the sources to your docker host and build the container, and to run.
```
	docker build --rm -t nowage/pyspark-notebook .
	docker run -it --name sp2 nowage/pyspark-notebook
```
Get the port that the container is listening on:

```
# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
ad2ad96e4b2f        nowage/pyspark-notebook "/bin/bash"         7 seconds ago       Up 6 seconds                            sp2
```

To test, ("nowage" is username. )
```
	sudo su -
```
To Rollback
```
    docker rm sp2 -f
    docker rmi nowage/pyspark-notebook
```
