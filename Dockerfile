FROM java:7

MAINTAINER Petri Sirkkala <sirpete@iki.fi>

USER root

RUN \
  apt-get update && \
  apt-get -y install \
    build-essential \
    iceweasel \
    git \
    maven \
    rsync \
    sudo \
    x11vnc \
    Xvfb && \
  rm -rf /var/lib/apt/lists/* # 2015-02-13

# Leiningen
ENV LEIN_ROOT 1
RUN curl -L -s https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein > \
    /usr/local/bin/lein \
 && chmod 0755 /usr/local/bin/lein \
 && lein upgrade

# Node
# Install Node.js, Bower, Grunt, Gulp
RUN \
  curl -sL https://deb.nodesource.com/setup | bash - && \
  apt-get -y install nodejs && \
  npm install -g npm@2.5.1 && \
  npm install -g bower@1.3.12 && \
  npm install -g grunt-cli@0.1.13 && \
  npm install -g gulp@3.8.11 && \
  echo 'export PATH="node_modules/.bin:$PATH"' >> /root/.bashrc && \
  echo 'export PATH="node_modules/.bin:$PATH"' >> /etc/skel/.bashrc && \
  chmod o+w -R /usr/local # Allow write for npm installs -g

ENV JENKINS_SWARM_VERSION 1.22
ENV HOME /home/jenkins-slave

RUN \
  useradd -c "Jenkins Slave user" -d $HOME -m jenkins-slave && \
  usermod -a -G sudo jenkins-slave && \
  echo "jenkins-slave ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/jenkins-slave && \
  curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar \
    http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar && \
  chmod 755 /usr/share/jenkins

USER jenkins-slave

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh
COPY bowerrc /home/jenkins-slave/.bowerrc

VOLUME /home/jenkins-slave

WORKDIR /home/jenkins-slave

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]
 HOME /home/jenkins-slave

RUN \
  useradd -c "Jenkins Slave user" -d $HOME -m jenkins-slave && \
  curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar \
    http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar && \
  chmod 755 /usr/share/jenkins

USER jenkins-slave

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh
COPY bowerrc /home/jenkins-slave/.bowerrc

VOLUME /home/jenkins-slave

WORKDIR /home/jenkins-slave

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]
