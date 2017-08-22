COMPOSE_FILE="docker-compose-2orgs-4peers.yaml"

all:
	echo "Please make sure u have setup Docker and pulled images by 'make setup'."
	sleep 2

	echo "Stop potential running network first"
	make stop

	make start
	sleep 3

	make init
	sleep 3

	make test
	sleep 3

	make stop

ready:
	make stop
	make start
	sleep 3

	make init
	sleep 3

	make test
	echo "Now the fabric network is ready to play"
	echo "run 'make cli' to enter into the fabric-cli container."
	echo "run 'make stop' when done."

setup: # setup the environment
	bash scripts/setup_Docker.sh  # Install Docker, Docker-Compose
	bash scripts/download_images.sh  # Pull required Docker images

start: # bootup the fabric network
	echo "Start a fabric network with 2-org-4-peer"
	docker-compose -f ${COMPOSE_FILE} up -d  # Start a fabric network

init: # initialize the fabric network
	echo "Install and instantiate cc example02 on the fabric network"
	docker exec -it fabric-cli bash ./scripts/initialize.sh

test: # test chaincode
	echo "Invoke and query cc example02"
	docker exec -it fabric-cli bash ./scripts/test_cc_invoke_query.sh

qscc: # test qscc quries
	docker exec -it fabric-cli bash ./scripts/test_qscc.sh

stop: # stop the fabric network
	echo "Stop the fabric network"
	docker-compose -f ${COMPOSE_FILE} down  # Stop a fabric network

clean: # clean up environment
	echo "Clean all images and containers"
	bash scripts/clean_env.sh

cli: # enter the cli container
	docker exec -it fabric-cli bash

ps: # show existing docker images
	docker ps -a

logs: # show logs
	docker-compose logs -f --tail 200
