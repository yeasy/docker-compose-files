# Kakfa

This project provides several useful Docker-Compose script to help quickly bootup a Kakfa network, and do simple testing with create topic, send&recv msg.

Currently we support Kakfa 2.13.*.

## Start

```bash
$ make start
```

## Test

Open a new shell to the cli container:

```bash
$ docker exec -it cli bash
```

In the container shell, create a new topic and wait for new msg  (dir default to KAFKA_HOME=/opt/kafka/).

```bash
# pwd
/opt/kafka

# bash /tmp/topic_create.sh
Create a topic test by connecting to zookeeper
Created topic test
bin/kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic test
Created topic test.

# bash /tmp/topic_list.sh
List all topics at zookeeper
bin/kafka-topics.sh --list --zookeeper zookeeper:2181
test

# export KAFKA_HOST=kafka1
# bash /tmp/msg_recv.sh
Recving msg to topic test by connecting to kafka1
bin/kafka-console-consumer.sh --bootstrap-server kafka1:9092 --topic test --from-beginning
```

Now open a new shell to the cli container.

```bash
# export KAFKA_HOST=kafka2
# bash /tmp/msg_send.sh
Send msg to topic test by connecting to kafka2
bin/kafka-console-producer.sh --broker-list kafka2:9092 --topic test
>msg_hello
```

Check the recving msg shell to get that msg.

## Stop

```bash
$ docker-compose down
```
