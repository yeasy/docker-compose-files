COMPOSE_FILE="docker-compose-2orgs-4peers.yaml"
COMPOSE_DEV_FILE="docker-compose-dev.yaml"
COMPOSE_COUCHDB_FILE="docker-compose-2orgs-4peers-couchdb.yaml"

all:
	@echo "Please make sure u have setup Docker and pulled images by 'make setup'."
	sleep 2

	make ready
	make lscc qscc

	make stop

ready:
	@echo "Restart and init network..."
	make restart init
	sleep 2

	make test_cc
	@echo "Now the fabric network is ready to play"
	@echo "run 'make cli' to enter into the fabric-cli container."
	@echo "run 'make stop' when done."

start: # bootup the fabric network
	@echo "Start a fabric network with 2-org-4-peer"
	docker-compose -f ${COMPOSE_FILE} up -d  # Start a fabric network

init: # initialize the fabric network
	@echo "Install and instantiate cc example02 on the fabric network"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/initialize_all.sh"


stop: # stop the fabric network
	@echo "Stop the fabric network"
	docker-compose -f ${COMPOSE_FILE} down  # Stop a fabric network

restart: stop start

################## Dev testing ################
dev:
	@echo "Please make sure u have setup Docker and pulled images by 'make setup'."
	sleep 2

	@echo "Restart and init dev network..."
	make dev_restart dev_init
	sleep 2

	make test_peer0
	make lscc qscc

	make dev_stop

dev_start: # start fabric network for dev
	@echo "Start a fabric network with 1 peer for dev"
	docker-compose -f ${COMPOSE_DEV_FILE} up -d

dev_init: # initialize the fabric network
	@echo "Install and instantiate cc example02 on the fabric dev network"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/initialize_peer0.sh"

dev_stop: # stop the fabric network for dev
	@echo "Stop the fabric network with 1 peer for dev"
	docker-compose -f ${COMPOSE_DEV_FILE} down

dev_restart: dev_stop dev_start

################## Couchdb testing ################
couch:
	@echo "Please make sure u have setup Docker and pulled images by 'make setup'."
	sleep 2

	make couch_ready

	make lscc qscc

	make dev_stop

couch_ready:
	@echo "Restart and init network with couchdb..."
	make couch_restart couch_init
	sleep 2

	make test_cc
	@echo "Now the fabric network is ready to play"
	@echo "run 'make cli' to enter into the fabric-cli container."
	@echo "run 'make stop' when done."

couch_start: # start fabric network with couchdb
	@echo "Start a fabric network with couchdb"
	docker-compose -f ${COMPOSE_COUCHDB_FILE} up -d

couch_init: # initialize the fabric network
	@echo "Install and instantiate cc example02 on the fabric dev network"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/initialize_all.sh"

couch_stop: # stop the fabric network with couchdb
	@echo "Stop the fabric network with 1 peer with couchdb"
	docker-compose -f ${COMPOSE_COUCHDB_FILE} down

couch_restart: couch_stop couch_start

################## Chaincode testing operations ################
test_cc: # test user chaincode on all peers
	@echo "Invoke and query cc example02 on all peers"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_cc_all.sh"

test_peer0: # test single peer
	@echo "Invoke and query cc example02 on single peer0"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_cc_peer0.sh"

qscc: # test qscc quries
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_qscc.sh"

lscc: # test lscc quries
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_lscc.sh"

################## Env setup related, no need to see usually ################

setup: # setup the environment
	bash scripts/setup_Docker.sh  # Install Docker, Docker-Compose
	bash scripts/download_images.sh  # Pull required Docker images

clean: # clean up environment
	@echo "Clean all images and containers"
	bash scripts/clean_env.sh

cli: # enter the cli container
	docker exec -it fabric-cli bash

ps: # show existing docker images
	docker ps -a

logs: # show logs
	docker-compose -f ${COMPOSE_FILE} logs -f --tail 200

