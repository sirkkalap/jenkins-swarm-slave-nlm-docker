#!/bin/bash

if [[ $(docker info) != *"Kernel Version:"* ]]; then
    echo "Unable to connect with Docker."
    exit 1
fi

PROJECT=jenkins-swarm-slave-nlm

read -r -d '' SCRIPT <<- End
    PORT=2376 /usr/local/bin/wrapdocker &
    export DOCKER_HOST=tcp://127.0.0.1:2376
    cd $PROJECT
    docker build -t sirkkalap/jenkins-swarm-slave-nlm:latest .
End

# https://github.com/sirkkalap/jenkins-swarm-slave-nlm-docker
IMG=jpetazzo/dind
MOUNT="-v $(pwd):/$PROJECT"
NAME="--name $PROJECT"
OPTS="-it --privileged --sig-proxy=true"

docker rm -f $PROJECT 2>/dev/null # Clean up old builds
docker run $OPTS $NAME $MOUNT $IMG /bin/bash -c "$SCRIPT"
