# dockerfiles-centos-user-adderable
mysql

# Building & Running

Copy the sources to your docker host and build the container, and to run.
```
  docker build --rm -t nowage/mysql .

	cname=mys

	docker rm -f $cname
	rm -f ~/df/Mysql/data
	rm -f ~/df/Mysql/work
	mkdir -p ~/df/Mysql/data
	mkdir -p ~/df/Mysql/work

	docker run                           \
	    -d                               \
	    --rm                             \
	    --name $cname                       \
	    -p 8081:8080                     \
	    -p 3307:3306                     \
	    -v ~/df/Mysql/data:/var/lib/mysql/   \
	    -v ~/df/Mysql/work:/root/work        \
	    -e MYSQL_ROOT_PASSWORD=nowage  \
	    nowage/mysql
	docker logs -f  $cname
```
Get the port that the container is listening on:

```
# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
ad2ad96e4b2f        nowage/mysql      "/bin/bash"         7 seconds ago       Up 6 seconds                            mys
```

To test,
```
	docker exec -it mys bash
	     $ mysql -uroot -p
			    passwd : nowage
```
To Rollback
```
    docker rm mys -f
    docker rmi nowage/mysql
```
