FROM java:8

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
# Install Node.js
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
  echo -e '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

# Bower
RUN npm install -g bower@1.3.12

# Grunt
RUN npm install -g grunt-cli@0.1.13

# # Allow write for npm install -g
RUN chmod o+w -R /usr/local/lib/node_modules

ENV JENKINS_SWARM_VERSION 1.22
ENV HOME /home/jenkins-slave

RUN useradd -c "Jenkins Slave user" -d $HOME -m jenkins-slave
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar \
  && chmod 755 /usr/share/jenkins

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

USER jenkins-slave

VOLUME /home/jenkins-slave

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]
