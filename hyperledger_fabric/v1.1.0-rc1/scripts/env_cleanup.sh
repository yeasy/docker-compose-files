#!/usr/bin/env bash

# This script will remove all containers and hyperledger related images

echo "Clean up all containers..."
docker rm -f `docker ps -qa`

echo "Clean up all chaincode images..."
docker rmi -f $(docker images |grep 'dev-peer'|awk '{print $3}')

echo "Clean up all hyperledger related images..."
docker rmi -f $(docker images |grep 'hyperledger'|awk '{print $3}')

echo "Clean up dangling images..."
docker rmi $(docker images -q -f dangling=true)

echo "Env cleanup done!"