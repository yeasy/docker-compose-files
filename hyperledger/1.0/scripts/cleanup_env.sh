#!/usr/bin/env bash

# This script will remove all containers and hyperledger related images

# Detecting whether can import the header file to render colorful cli output
if [ -f ./header.sh ]; then
 source ./header.sh
elif [ -f worker_node_setup/header.sh ]; then
 source scripts/header.sh
else
 alias echo_r="echo"
 alias echo_g="echo"
 alias echo_b="echo"
fi

echo_b "Clean up all containers..."
docker rm -f `docker ps -qa`

echo_b "Clean up all hyperledger related images..."
docker rmi $(docker images |grep 'hyperledger')

echo_g "Env cleanup done!"
