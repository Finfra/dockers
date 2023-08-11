# dockerfiles-centos-user-adderable
Nginx install : Use for Docker and Kubernetes

# Building & Running

Copy the sources to your docker host and build the container, and to run.
```
	docker build --rm -t nowage/nginx .
	docker run -d --name n1 -p 8888:80 nowage/nginx
```
Get the port that the container is listening on:

```
# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
ad2ad96e4b2f        nowage/nginx      "/bin/bash"         7 seconds ago       Up 6 seconds                            n1
```

To test, ("nowage" is username. )
```
	open 127.0.0.1:8888
```
To Rollback
```
    docker rm n1 -f
    docker rmi nowage/nginx
```

# Example : Test for Kubernetes 
```
docker login
docker push nowage/nginx
kubectl create deployment --image=nowage/nginx --port=80 n1
kubectl expose deploy n1 --type=NodePort
echo nodePort : $(k get svc n1 -o jsonpath="{.spec.ports[0].nodePort}")
```


