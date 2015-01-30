FROM sirkkalap/jenkins-swarm-slave-w-lein:java7

MAINTAINER Petri Sirkkala <sirpete@iki.fi>

USER root

RUN apt-get update

# Install git (just for fun :)
RUN apt-get -y install git

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get -y install nodejs build-essential

# Update NPM
RUN npm install -g npm

# Bower
RUN npm install -g bower

# Grunt
RUN npm install -g grunt-cli

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

USER jenkins-slave
WORKDIR /home/jenkins-slave