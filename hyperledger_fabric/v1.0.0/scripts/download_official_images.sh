#!/bin/bash

if [ -f ./header.sh ]; then
 source ./header.sh
elif [ -f scripts/header.sh ]; then
 source scripts/header.sh
else
 alias echo_r="echo"
 alias echo_g="echo"
 alias echo_b="echo"
fi

echo_b "===Download official images from https://hub.docker.com/u/hyperledger/"

# pull fabric images
ARCH=x86_64
BASEIMAGE_RELEASE=0.3.1
PROJECT_VERSION=1.0.0
IMG_TAG=1.0.0

echo_b "===Pulling fabric images... with tag = ${IMG_TAG}"
docker pull hyperledger/fabric-peer:$ARCH-$IMG_TAG
docker pull hyperledger/fabric-tools:$ARCH-$IMG_TAG
docker pull hyperledger/fabric-orderer:$ARCH-$IMG_TAG
docker pull hyperledger/fabric-ca:$ARCH-$IMG_TAG
docker pull hyperledger/fabric-ccenv:$ARCH-$IMG_TAG
docker pull hyperledger/fabric-baseimage:$ARCH-$BASEIMAGE_RELEASE
docker pull hyperledger/fabric-baseos:$ARCH-$BASEIMAGE_RELEASE
docker pull hyperledger/fabric-couchdb:$ARCH-$IMG_TAG
docker pull hyperledger/fabric-kafka:$ARCH-$IMG_TAG
docker pull hyperledger/fabric-zookeeper:$ARCH-$IMG_TAG

echo_b "===Re-tagging images to *latest* tag"
docker tag hyperledger/fabric-peer:$ARCH-$IMG_TAG hyperledger/fabric-peer
docker tag hyperledger/fabric-tools:$ARCH-$IMG_TAG hyperledger/fabric-tools
docker tag hyperledger/fabric-orderer:$ARCH-$IMG_TAG hyperledger/fabric-orderer
docker tag hyperledger/fabric-ca:$ARCH-$IMG_TAG hyperledger/fabric-ca
docker tag hyperledger/fabric-zookeeper:$ARCH-$IMG_TAG hyperledger/fabric-zookeeper
docker tag hyperledger/fabric-kafka:$ARCH-$IMG_TAG hyperledger/fabric-kafka
docker tag hyperledger/fabric-couchdb:$ARCH-$IMG_TAG hyperledger/fabric-couchdb

echo_b "Done, now can startup the network using docker-compose..."
