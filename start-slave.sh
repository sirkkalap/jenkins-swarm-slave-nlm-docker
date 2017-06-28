#!/bin/bash
MASTER=${1:?Master url is the first required parameter. For example: http://192.168.50.100:8080 .}
USERNAME=${2:?Username (for the master) is the second required parameter.}
PASSWORD=${3:?Password (for the master) is the third required parameter.}
IMAGE=${4:?Image is the fourth required parameter. For example: sirkkalap/jenkins-swarm-slave-nlm:latest}
# See: https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/
USE_SIBLING_CONTAINERS="-v /var/run/docker.sock:/var/run/docker.sock"
docker run -i --rm \
  -e "JAVA_OPTS=-Dfile.encoding=UTF8" \
  $USE_SIBLING_CONTAINERS \
  $IMAGE \
  -master $MASTER \
  -labels lein -labels node -labels firefox -labels maven -labels xvfb \
  -username $USERNAME -password $PASSWORD \
  -executors 1
