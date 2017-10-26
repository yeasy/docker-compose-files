Docker Compose Files
===
Some typical docker compose examples.

If you're not familiar with Docker, can have a look at these books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)

# Install Docker&Docker Compose

```bash
$ curl -sSL https://get.docker.com/ | sh
$ sudo pip install docker-compose
```

# Docker-compose Usage
See [Docker Compose Documentation](https://docs.docker.com/compose/).


# Examples files

## [consul-discovery](consul-discovery)
Using consul to make a service-discoverable architecture.

## [elk_netflow](elk_netflow)
Elk cluster, with netflow support.
```sh
docker-compose scale es=3
```

## [haproxy_web](haproxy_web)
A simple haproxy and web applications cluster.

## [hyperledger_fabric](hyperledger_fabric)
Quickly bootup a hyperledger fabric cluster with several validator nodes, without vagrant or any manual configuration.

Now we support from v0.6 to v1.0.x.

See [hyperledger_fabric](hyperledger_fabric) for more details.

## [kafka](kafka)
Start a simple kafka service for testing.

## [mongo_cluster](mongo_cluster)
Start 3 mongo instance to make a replica set.

## [mongo-elasticsearch](mongo-elasticsearch)
Start mongo (as cluster) and elasticsearch, use a mongo-connector to sync the data from mongo to elasticsearch.

## [mongo_webui](mongo_webui)
Start 1 mongo instance and a mongo-express web tool to watch it.

The mongo instance will store data into local /opt/data/mongo_home.

The web UI will listen on local 8081 port.

## [nginx_auth](nginx_auth)
Use nginx as a proxy with authentication for backend application.

## [packetbeat_ek](packetbeat_ek)
Demo the packetbeat, elasticsearch and kibana.

Some kibana [dashboard config](https://github.com/elastic/beats-dashboards) files are included.

To import them, after all containers startup, go inside the kibana container, and run
```sh
$ cd /kibana/beats-dashboards-1.0.1 && ./load.sh http://elasticsearch:9200
```

## [registry_mirror](registry_mirror)
docker registry mirror, with redis as the backend cache.

## [spark_cluster](spark_cluster)
Spark cluster with master and worker nodes.
```sh
docker-compose scale worker=2
```
Try submitting a test pi application using the spark-submit command.
```sh
/urs/local/spark/bin/spark-submit --master spark://master:7077 --class org.apache.spark.examples.SparkPi /usr/local/spark/lib/spark-examples-1.4.0-hadoop2.6.0.jar 1000
```
