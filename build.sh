#!/bin/bash

if [[ $(docker info) != *"Kernel Version:"* ]]; then
    echo "Unable to connect with Docker."
    exit 1
fi

PROJECT=jenkins-swarm-slave-nlm

read -r -d '' SCRIPT <<- End
    /usr/local/bin/wrapdocker
    docker build -t sirkkalap/jenkins-swarm-slave-nlm:java7 .
End

# https://github.com/sirkkalap/jenkins-swarm-slave-nlm-docker
IMG=jpetazzo/dind
MOUNT="-v $(pwd):/$PROJECT"
NAME="--name $PROJECT"
OPTS="-it --privileged --sig-proxy=true"

docker rm -f $PROJECT 2>/dev/null # Clean up old builds
docker run $OPTS $NAME $MOUNT $IMG /bin/bash -c "$SCRIPT"
