FROM java:7

MAINTAINER Petri Sirkkala <sirpete@iki.fi>

USER root

# Add Firefox & Chromium repos
RUN \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
  curl -sL http://packages.linuxmint.com/pool/main/l/linuxmint-keyring/linuxmint-keyring_2009.04.29_all.deb >linuxmint-keyring.deb && \
  echo "deb http://packages.linuxmint.com debian import" > /etc/apt/sources.list.d/linuxmint.list && \
  dpkg -i linuxmint-keyring.deb && \
  rm linuxmint-keyring.deb

RUN \
  apt-get update && \
  apt-get -y install \
    build-essential \
    firefox \
    git \
    google-chrome-stable \
    maven \
    x11vnc \
    Xvfb && \
  rm -rf /var/lib/apt/lists/* # 2015-02-07

# Leiningen
ENV LEIN_ROOT 1
RUN curl -L -s https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein > \
    /usr/local/bin/lein \
 && chmod 0755 /usr/local/bin/lein \
 && lein upgrade

# Node
# Install Node.js, Bower, Grunt, Gulp
RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/node-latest.tar.gz && \
  tar xvzf node-latest.tar.gz && \
  rm -f node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  npm install -g npm@2.5.0 && \
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
  curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar \
    http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar && \
  chmod 755 /usr/share/jenkins

USER jenkins-slave

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh
COPY bowerrc /home/jenkins-slave/.bowerrc

VOLUME /home/jenkins-slave

WORKDIR /home/jenkins-slave

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]
