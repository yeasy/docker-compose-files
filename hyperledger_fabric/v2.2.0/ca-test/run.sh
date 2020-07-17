#!/usr/bin/env bash

echo $PWD

docker-compose rm -f

rm -rf crypto-config/*

echo "starting ca server"
docker-compose up

docker-compose down
