COMPOSE_FILE="docker-compose-2orgs-4peers.yaml"
COMPOSE_DEV_FILE="docker-compose-dev.yaml"

all:
	@echo "Please make sure u have setup Docker and pulled images by 'make setup'."
	sleep 2

	@echo "Stop potential running network first"
	make stop

	make start
	sleep 1

	make init
	sleep 3

	make test_cc
	sleep 1

	make lscc
	sleep 1

	make qscc
	sleep 1

	make stop

dev:
	@echo "Please make sure u have setup Docker and pulled images by 'make setup'."
	sleep 2

	@echo "Stop potential running dev network first"
	make dev_stop

	make dev_start
	sleep 5

	make test_peer0

	make dev_stop

ready:
	make stop
	make start
	sleep 3

	make init
	sleep 3

	make test_cc
	@echo "Now the fabric network is ready to play"
	@echo "run 'make cli' to enter into the fabric-cli container."
	@echo "run 'make stop' when done."

setup: # setup the environment
	bash scripts/setup_Docker.sh  # Install Docker, Docker-Compose
	bash scripts/download_images.sh  # Pull required Docker images

start: # bootup the fabric network
	@echo "Start a fabric network with 2-org-4-peer"
	docker-compose -f ${COMPOSE_FILE} up -d  # Start a fabric network

init: # initialize the fabric network
	@echo "Install and instantiate cc example02 on the fabric network"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/initialize_all.sh"

test_cc: # test chaincode
	@echo "Invoke and query cc example02 on all peers"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_cc_all.sh"

test_peer0: # test single peer
	@echo "Invoke and query cc example02 on single peer0"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_cc_peer0.sh"

qscc: # test qscc quries
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_qscc.sh"

lscc: # test lscc quries
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_lscc.sh"

stop: # stop the fabric network
	@echo "Stop the fabric network"
	docker-compose -f ${COMPOSE_FILE} down  # Stop a fabric network

clean: # clean up environment
	@echo "Clean all images and containers"
	bash scripts/clean_env.sh

cli: # enter the cli container
	docker exec -it fabric-cli bash

ps: # show existing docker images
	docker ps -a

logs: # show logs
	docker-compose -f ${COMPOSE_FILE} logs -f --tail 200

dev_start: # start fabric network for dev
	@echo "Start a fabric network with 1 peer for dev"
	docker-compose -f ${COMPOSE_DEV_FILE} up -d

dev_stop: # stop the fabric network for dev
	@echo "Stop the fabric network with 1 peer for dev"
	docker-compose -f ${COMPOSE_DEV_FILE} down

