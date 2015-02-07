FROM sirkkalap/jenkins-swarm-slave-w-lein

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
    npm \
    x11vnc \
    Xvfb && \
  rm -rf /var/lib/apt/lists/* # 2015-02-07

# Update NPM
RUN npm install -g npm@2.5.0

# Bower
RUN npm install -g bower@1.3.12

# Grunt
RUN npm install -g grunt-cli@0.1.13

# Allow write for npm install -g
RUN chmod o+w -R /usr/lib/node_modules

USER jenkins-slave
WORKDIR /home/jenkins-slave