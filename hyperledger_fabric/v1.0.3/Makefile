# mode of the network: solo, kafka, couchdb, dev
HLF_MODE ?= solo

CODE_BUILD_WAIT=2
NETWORK_INIT_WAIT=2

COMPOSE_FILE ?= "docker-compose-2orgs-4peers-solo.yaml"

ifeq ($(HLF_MODE),kafka)
	COMPOSE_FILE="docker-compose-2orgs-4peers-kafka.yaml"
else ifeq ($(HLF_MODE),couchdb)
	COMPOSE_FILE="docker-compose-2orgs-4peers-couchdb.yaml"
else ifeq ($(HLF_MODE),dev)
	COMPOSE_FILE="docker-compose-1orgs-1peers-dev.yaml"
endif

all:
	@echo "Run test with $(COMPOSE_FILE)"
	@echo "Please make sure u have setup Docker and pulled images by 'make setup'."
	sleep 2

	make ready
	make lscc qscc fetch_block
	make stop clean

ready: restart
	@echo "Restart, init network and then do cc testing..."
	if [ "$(HLF_MODE)" = "dev" ]; then \
			echo "In DEV mode, wait for rebuilding ..." && sleep $(CODE_BUILD_WAIT); \
			make init_peer0; \
			sleep $(NETWORK_INIT_WAIT); \
			make test_cc_peer0; \
	else \
			echo "In Normal mode ..." && sleep 3; \
			make init; \
			sleep $(NETWORK_INIT_WAIT); \
			make test_cc_all; \
	fi

	@echo "Now the fabric network is ready to play"
	@echo "run 'make cli' to enter into the fabric-cli container."
	@echo "run 'make stop' when done."

start: # bootup the fabric network
	@echo "Start a fabric network with ${COMPOSE_FILE}"
	make clean
	docker-compose -f ${COMPOSE_FILE} up -d  # Start a fabric network

init: # initialize the fabric network
	@echo "Install and instantiate cc example02 on the fabric network"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/initialize_all.sh"

init_peer0: # initialize the fabric network
	@echo "Install and instantiate cc example02 on the fabric dev network"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/initialize_peer0.sh"

stop: # stop the fabric network
	@echo "Stop the fabric network"
	docker-compose -f ${COMPOSE_FILE} down  # Stop a fabric network

restart: stop start

chaincode_dev: restart chaincode_init test_cc_peer0 stop

################## Chaincode testing operations ################
test_cc_all: # test user chaincode on all peers
	@echo "Invoke and query cc example02 on all peers"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_cc_all.sh"

test_cc_peer0: # test single peer
	@echo "Invoke and query cc example02 on single peer0"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_cc_peer0.sh"

qscc: # test qscc queries
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_qscc.sh"

lscc: # test lscc quries
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_lscc.sh"

fetch_block: # test channel fetch
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/test_fetch.sh"
	docker cp fabric-cli:/tmp/block_0.block kafka/channel-artifacts/
	docker cp fabric-cli:/tmp/block_1.block kafka/channel-artifacts/
	docker cp fabric-cli:/tmp/block_2.block kafka/channel-artifacts/
	docker cp fabric-cli:/tmp/block_3.block kafka/channel-artifacts/


################## Env setup related, no need to see usually ################

setup: # setup the environment
	bash scripts/setup_Docker.sh  # Install Docker, Docker-Compose
	bash scripts/download_images.sh  # Pull required Docker images

clean: # clean up containers
	@echo "Clean all containers and fabric cc images"
	@-docker rm -f `docker ps -qa`
	@-docker rmi $$(docker images | awk '$$1 ~ /dev-peer/ { print $$3}')

clean_env: # clean up environment
	@echo "Clean all images and containers"
	bash scripts/clean_env.sh

cli: # enter the cli container
	docker exec -it fabric-cli bash

peer: # enter the peer container
	docker exec -it peer0.org1.example.com bash

dev_compile: # rebuild the peer
	docker exec -it peer0.org1.example.com bash /tmp/peer_build.sh

ps: # show existing docker images
	docker ps -a

logs: # show logs
	docker-compose -f ${COMPOSE_FILE} logs -f --tail 200

logs_check: logs_save logs_view

logs_save: # save logs
	docker logs peer0.org1.example.com >& /tmp/dev_peer.log
	docker logs orderer.example.com >& /tmp/dev_orderer.log
	docker-compose -f ${COMPOSE_FILE} logs >& /tmp/dev_all.log

logs_view: # view logs
	less /tmp/dev_peer.log

gen_solo: # generate solo artifacts
	cd solo && bash gen_artifacts.sh

gen_kafka: # generate kafka artifacts
	cd kafka && bash gen_artifacts.sh

configtxlator: # run configtxlator
	cd kafka && bash run_configtxlator.sh

download: # download required images
	@echo "Download Docker images"
	docker pull yeasy/hyperledger-fabric:latest
	docker pull yeasy/hyperledger-fabric-kafka:0.10.2.0  # official repo does not provide the latest image currently
	docker pull hyperledger/fabric-baseos:x86_64-0.4.2
	docker tag yeasy/hyperledger-fabric:latest hyperledger/fabric-ccenv:x86_64-1.1.0


################## chaincode dev mode ################
chaincode_init: # start chaincode in dev mode and do install/instantiate
	@echo "Install and instantiate cc example02 on the fabric dev network"
	docker exec -it fabric-cli bash -c "cd /tmp; bash scripts/init_chaincode_dev.sh"

