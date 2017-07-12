#!/usr/bin/env bash

# Detecting whether can import the header file to render colorful cli output
if [ -f ./header.sh ]; then
 source ./header.sh
elif [ -f scripts/header.sh ]; then
 source scripts/header.sh
else
 alias echo_r="echo"
 alias echo_g="echo"
 alias echo_b="echo"
fi

COMPOSE_FILE=${1:-"docker-compose-2orgs-4peers.yaml"}

echo_b "Start up with ${COMPOSE_FILE}"

docker-compose -f ${COMPOSE_FILE} up -d
