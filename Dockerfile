# Based on https://github.com/rancher/jenkins-slave
FROM ubuntu:16.04

RUN apt-get update \
 && apt-get -y install \
        apt-transport-https \
        curl \
        git \
        software-properties-common \
 && rm -rf /var/lib/apt/lists/*

# Install the Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
 && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" \
 && apt-get update \
 && apt-get -q -y install docker-ce \
 && rm -rf /var/lib/apt/lists/*

# Install the official java
RUN add-apt-repository ppa:webupd8team/java -y \
 && apt-get update \
 && (echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections) \
 && apt-get install -y \
        oracle-java8-installer \
        oracle-java8-set-default \
 && rm -rf /var/lib/apt/lists/*

# Java environment
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH $JAVA_HOME/bin:$PATH

# Jenkins swarm
ENV JENKINS_SWARM_VERSION 3.10
ENV HOME /home/jenkins-slave

RUN useradd -c "Jenkins Slave user" -d $HOME -m jenkins-slave \
 && usermod -aG docker jenkins-slave \
 && curl --create-dirs -sSLo $HOME/swarm-client-$JENKINS_SWARM_VERSION.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
 && mkdir /var/jenkins \
 && chown jenkins-slave:jenkins-slave /var/jenkins
COPY entrypoint.sh /entrypoint.sh

USER jenkins-slave

#ENV JENKINS_USERNAME jenkins
#ENV JENKINS_PASSWORD jenkins
#ENV JENKINS_MASTER http://jenkins:8080

VOLUME ["/var/jenkins"]

ENTRYPOINT ["/entrypoint.sh"]
