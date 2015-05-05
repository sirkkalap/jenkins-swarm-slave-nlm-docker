jenkins-swarm-slave-nlm-docker
==============================

Renamed to work around possible Docker Hub restriction on branch name. It seems that hyphen is not allowed or something...

Jenkins Swarmer slave with nodejs, Leiningen, Maven, Xvfb and Firefox

# Running

```bash
    docker run --rm --link jenkins-master:jenkins \
    sirkkalap/jenkins-swarm-slave-nlm-docker:latest \
    -username jenkins -password jenkins -executors 1
```

# Building

```bash
    docker build -t sirkkalap/jenkins-swarm-nlm-docker .
```
