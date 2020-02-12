
download:
	docker pull yeasy/kafka:latest

start:
	docker stack deploy --compose-file docker-compose.yaml zk
stop:
	docker stack rm zk

restart: stop start

zookeeper:
	docker exec -it zookeeper1 bash
kafka:
	docker exec -it kafka1 bash

cli:
	docker exec -it cli bash
