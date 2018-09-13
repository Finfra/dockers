# dockerfiles-centos-user-adderable
mysql

# Building & Running

Copy the sources to your docker host and build the container, and to run.
```
	docker build --rm -t nowage/mysql .
	docker run -it --name mys -e -p 8081:8080                     \
    -p 3307:3306                                                 \
    -v /Users/nowage/df/Mysql/data:/var/lib/mysql/               \
    -v /Users/nowage/df/work:/work                               \
    -v /Users/nowage/df/_src/:/_src                              \
    -e MYSQL_ROOT_PASSWORD=nowage                                \
    nowage/mysql
```
Get the port that the container is listening on:

```
# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
ad2ad96e4b2f        nowage/mysql      "/bin/bash"         7 seconds ago       Up 6 seconds                            mys
```

To test, ("nowage" is username. )
```
	su - nowage
```
To Rollback
```
    docker rm mys -f
    docker rmi nowage/mysql
```
