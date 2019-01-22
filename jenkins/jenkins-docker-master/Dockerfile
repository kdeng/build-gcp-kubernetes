FROM jenkins/jenkins:lts

# Distributed Builds plugins
RUN /usr/local/bin/install-plugins.sh ssh-slaves \
  email-ext \
  mailer \
  htmlpublisher \
  greenballs \
  simple-theme-plugin \
  kubernetes

# install Maven
USER root
RUN apt-get update && apt-get install -y maven

COPY groovy/executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

# Switch user to jenkins
USER jenkins
