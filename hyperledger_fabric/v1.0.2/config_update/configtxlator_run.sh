#!/bin/bash


echo "Start configtxlator service and listen on port 7059"
docker run \
	--rm -it \
	--name configtxlator \
	-p 7059:7059 \
	yeasy/hyperledger-fabric \
	configtxlator start


docker rm -f configtxlator
