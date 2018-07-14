FROM debian:stretch-slim

ENV SCALA_VERSION 2.12
ENV KAFKA_VERSION 1.1.0
ENV KAFKA_HOME /opt/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION"

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		apt-transport-https vim procps wget gnupg iputils-ping dnsutils
##################################################################
## Supervisor 
##################################################################

RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
	
RUN mkdir /usr/share/man/man1 -p
RUN apt-get install -y --no-install-recommends openjdk-8-jre-headless libcap2-bin

# ci-dessous peut etre pas util
RUN setcap cap_net_bind_service=+epi /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java


# Install Kafka, Zookeeper and other needed things
RUN apt-get install -y zookeeper
# For test kafka offline version available in ./kafka-src
#RUN wget -q http://apache.mirrors.spacedump.net/kafka/"$KAFKA_VERSION"/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -O /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz 
COPY ./kafka-src/kafka_2.12-1.1.0.tgz /tmp/  
RUN tar xfz /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -C /opt && \
    rm /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz

ADD scripts/start-kafka.sh /usr/bin/start-kafka.sh

RUN ln -s "$KAFKA_HOME/logs" /var/log/kafka-logs

# Supervisor config
ADD supervisor/kafka.conf supervisor/zookeeper.conf /etc/supervisor/conf.d/
# Vim configuration
ADD configs/.vimrc /root/.vimrc

# -----------------------
# Configuration logrotate
# -----------------------
RUN apt-get install -y --no-install-recommends logrotate

COPY logrotate/logrotate.conf /etc/


# ------------------
# Configuration Cron
# ------------------

COPY cron/crontab /etc/crontab
RUN chmod 600 /etc/crontab

RUN ln -snf /usr/share/zoneinfo/Europe/Paris /etc/localtime && echo Europe/Paris > /etc/timezone



RUN apt-get install -y --no-install-recommends kafkacat
# 2181 is zookeeper, 9092/9094 is kafka, 9001 is JMX
EXPOSE 2181 9092 9094 9001

VOLUME ["/tmp/kafka-logs","/var/log/zookeeper","/var/log/kafka-logs"]

CMD ["/usr/bin/supervisord","-n"]
