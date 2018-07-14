# TODO
ne plus lancer le supervisor en root
faire fonctionner le logrotate
voir le mode creation automatique de topic

# Build

docker build -t daki/kafka .

# Volume

+ /tmp/kafka-logs
données du broker

+ /var/log/zookeeper
log du zookeeper

+ /var/log/kafka-logs
log de kafka

# Services

Supervisord supervise deux services :
* kafka
=> /usr/bin/start-kafka.sh va alimenter le fichier server.properties ($KAFKA_HOME/config/server.properties) sur base des variables 
définies dans docker-compose

* zookeeper

# Paramètres de docker-compose

* ADVERTISED_HOST: 
  the external ip for the container, e.g. 
* ADVERTISED_PORT: 
  the external port for Kafka, e.g. 9092
* ZK_CHROOT: 
  the zookeeper chroot that's used by Kafka (without / prefix), e.g. "kafka"
* LOG_RETENTION_HOURS: 
  the minimum age of a log file in hours to be eligible for deletion (default is 168, for 1 week)
* LOG_RETENTION_BYTES: 
  configure the size at which segments are pruned from the log, (default is 1073741824, for 1GB)
* NUM_PARTITIONS: 
  configure the default number of log partitions per topic
* BROKER_ID:
  id du broker doit etre unique (et au format numerique)
* ZOO_LOG_DIR: 
  repertoire des logs du zookeeper (disponible dans un volume)

# Outil

Initialisation d'un producer qui va envoyer les données saisies sur l'entrée standard dans le topic syslog
kafkacat -b 192.168.2.38 -t syslog -P

Initialisation d'un consumer qui écoute sur le topic syslog en démarrant à l'offset 2
kafkacat -b 192.168.2.38 -t syslog -o 2
