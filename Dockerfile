FROM java:8

MAINTAINER Petri Sirkkala <sirpete@iki.fi>

USER root

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

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

# From: https://registry.hub.docker.com/u/selenium/node-base/dockerfile/
#===============
# Google Chrome
#===============
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    google-chrome-stable \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/*

#==================
# Chrome webdriver
#==================
ENV CHROME_DRIVER_VERSION 2.14
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

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
  chmod o+w -R /usr/local # Allow write for npm installs -g # 2015-05-18

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