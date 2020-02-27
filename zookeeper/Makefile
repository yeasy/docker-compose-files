
download:
	docker pull yeasy/zookeeper:latest

start:
	# for swarm service mode
	docker stack deploy --compose-file docker-compose.yaml zk
	#docker-compose up
stop:
	# for swarm service mode
	docker stack rm zk
	#docker-compose down

restart: stop start

zookeeper:
	docker exec -it zookeeper1 bash

cli:
	docker exec -it cli bash

test:
	docker exec -it cli bash -c 'bash /opt/zookeeper/bin/zkCli.sh -server zk_zookeeper1:2181'
