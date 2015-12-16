# Cloudera Agent
# v1.1

FROM ubuntu:14.04
MAINTAINER Anton Pestov <anton@docker.com>

#SSH
RUN apt-get -qq update && apt-get -qq install -y openssh-server curl
RUN mkdir /var/run/sshd
RUN echo 'root:Qwerty1' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

# Add a Repository Key
RUN curl -L https://archive.cloudera.com/cm5/ubuntu/trusty/amd64/cm/cloudera.list -o /etc/apt/sources.list.d/cloudera.list
# Add the Cloudera Public GPG Key to your repository
RUN curl -L https://archive.cloudera.com/cm5/ubuntu/trusty/amd64/cm/archive.key -o archive.key
RUN apt-key add archive.key
# Clean repository cache
RUN apt-get -qq update

RUN apt-get -qq install -y oracle-j2sdk1.7 cloudera-manager-agent cloudera-manager-daemons

RUN server_ip=$1
RUN service cloudera-scm-agent stop
RUN sed -i "s/server_host=localhost/server_host=${server_ip}/g" /etc/cloudera-scm-agent/config.ini
#[ ! -z "$CM_SERVER_IP" ] && configure_agent $CM_SERVER_IP
RUN service cloudera-scm-agent restart

#CM_LOG=/var/log/cloudera-scm-agent/cloudera-scm-agent.log
#until [ -f $CM_LOG ]; do echo "waiting for $CM_LOG to exist"; sleep 10; done
#tail -f $CM_LOG
