FROM sirkkalap/jenkins-swarm-slave-w-lein

MAINTAINER Petri Sirkkala <sirpete@iki.fi>

USER root

RUN apt-get update

# Maven
RUN apt-get -y install maven

# Xvfb
RUN apt-get -y install Xvfb

# x11vnc for remote debugging
RUN apt-get -y install x11vnc

# Firefox
RUN echo "deb http://packages.linuxmint.com debian import" >>/etc/apt/sources.list
RUN curl -sL http://packages.linuxmint.com/pool/main/l/linuxmint-keyring/linuxmint-keyring_2009.04.29_all.deb >linuxmint-keyring.deb
RUN dpkg -i linuxmint-keyring.deb && rm linuxmint-keyring.deb
RUN apt-get update
RUN apt-get -y install firefox

# Install Chromium.
RUN \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
  apt-get update && \
  apt-get install -y google-chrome-stable && \
  rm -rf /var/lib/apt/lists/*

# Install git (just for fun :)
RUN apt-get -y install git

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get -y install nodejs build-essential

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