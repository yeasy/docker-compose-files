#! /bin/bash

COMPOSE_FILE=${1:-"docker-compose.yml"}

bash ./setup_Docker.sh

bash ./download_images.sh

echo "Start up with ${COMPOSE_FILE}"

docker-compose -f ${COMPOSE_FILE} up -d
