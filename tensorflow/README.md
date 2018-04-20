# Tensorflow Docker Image from tensorflow/tensorflow
## Version info
* Tensorflow : 1.7
* Python : 3.5


# Building & Running

Copy the sources to your docker host and build the container, and to run.
```
	docker build --rm -t nowage/tensorflow .
	docker run -it --rm                   \
	    --name=t1                         \
	    -v /Users/nowage/df:/notebooks/df \
	    -v /Users/nowage/__git/nowage/TensorflowStudyExample:/notebooks/TensorflowStudyExample \
	    -p 8888:8888                      \
	    -p 2222:22                        \
	    -p 6006:6006                      \
	    nowage/tensorflow
```
Get the port that the container is listening on:

```
# docker ps
CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS               NAMES
ad2ad96e4b2f        nowage/tensorflow      "/bin/bash"         7 seconds ago       Up 6 seconds                            t1
```

To Rollback
```
    docker rm t1 -f
    docker rmi nowage/tensorflow
```
