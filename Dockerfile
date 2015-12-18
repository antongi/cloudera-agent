# Cloudera Agent
# v1.4

FROM ubuntu:14.04
MAINTAINER Anton Pestov <anton@docker.com>

ARG CM_SERVER_URL

#SSH
RUN apt-get -qq update && apt-get -qq install -y openssh-server curl
RUN mkdir /var/run/sshd
#RUN echo 'root:pass' | chpasswd
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

RUN service cloudera-scm-agent stop
RUN sed -i "s|server_host=.*|server_host=${CM_SERVER_URL}|" /etc/cloudera-scm-agent/config.ini
RUN service cloudera-scm-agent restart
