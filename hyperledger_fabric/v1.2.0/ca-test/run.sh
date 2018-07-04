#!/usr/bin/env bash

echo $PWD

docker-compose rm -f

rm -rf fabric-ca-client/Admin@org1.example.com
rm -rf fabric-ca-server/ca.org1.example.com
rm -rf fabric-ca-server/tlsca.org1.example.com

echo "starting ca server"
docker-compose up

docker-compose down
