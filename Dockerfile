# Based on https://github.com/rancher/jenkins-slave
FROM ubuntu:xenial

USER root

RUN apt-get update \
 && apt-get -y upgrade \
 && apt-get -y install \
        curl \
        apt-transport-https \
        software-properties-common \
        git

# Install the Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
 && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" \
 && apt-get update \
 && apt-get -q -y install docker-ce

# Install the official java
RUN add-apt-repository ppa:webupd8team/java -y \
 && apt-get update \
 && (echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections) \
 && apt-get install -y oracle-java8-installer oracle-java8-set-default

# Spring cleaning
RUN apt-get -q autoremove \
 && apt-get -q clean -y

# Java environment
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH $JAVA_HOME/bin:$PATH

# Jenkins swarm
ENV JENKINS_SWARM_VERSION 3.8
ENV HOME /home/jenkins-slave

RUN useradd -c "Jenkins Slave user" -d $HOME -m jenkins-slave \
 && curl --create-dirs -sSLo $HOME/swarm-client-$JENKINS_SWARM_VERSION.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar
ADD cmd.sh /cmd.sh

#ENV JENKINS_USERNAME jenkins
#ENV JENKINS_PASSWORD jenkins
#ENV JENKINS_MASTER http://jenkins:8080

CMD /bin/bash /cmd.sh
