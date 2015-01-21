jenkins-swarm-slave-nlm-docker
==============================

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
