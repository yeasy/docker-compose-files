#!/usr/bin/env bash

ARCH=x86_64

# for the base images, including baseimage, baseos, couchdb, kafka, zookeeper
BASE_IMG_TAG=0.3.2

# For fabric images, including peer, orderer, ca
FABRIC_IMG_TAG=1.0.5

echo "Downloading images from DockerHub... need a while"

echo "===Pulling base images from yeasy repo... with tag = ${BASE_IMG_TAG}"
docker pull hyperledger/fabric-baseimage:$ARCH-$BASE_IMG_TAG
docker pull hyperledger/fabric-baseos:$ARCH-$BASE_IMG_TAG
docker pull hyperledger/fabric-couchdb:$ARCH-$BASE_IMG_TAG
docker pull hyperledger/fabric-kafka:$ARCH-$BASE_IMG_TAG
docker pull hyperledger/fabric-zookeeper:$ARCH-$BASE_IMG_TAG

# TODO: we may need some checking on pulling result?
echo "===Pulling fabric images from yeasy repo... with tag = ${FABRIC_IMG_TAG}"
docker pull yeasy/hyperledger-fabric-base:$FABRIC_IMG_TAG \
  && docker pull yeasy/hyperledger-fabric-peer:$FABRIC_IMG_TAG \
  && docker pull yeasy/hyperledger-fabric-orderer:$FABRIC_IMG_TAG \
  && docker pull yeasy/hyperledger-fabric:$FABRIC_IMG_TAG \
  && docker pull yeasy/hyperledger-fabric-ca:$FABRIC_IMG_TAG \
	&& docker pull docker pull yeasy/blockchain-explorer:0.1.0-preview  # TODO: wait for official images

# Only useful for debugging
# docker pull yeasy/hyperledger-fabric

echo "===Pulling fabric images from official repo... with tag = ${FABRIC_IMG_TAG}"
docker pull hyperledger/fabric-peer:$ARCH-$FABRIC_IMG_TAG
docker pull hyperledger/fabric-tools:$ARCH-$FABRIC_IMG_TAG
docker pull hyperledger/fabric-orderer:$ARCH-$FABRIC_IMG_TAG
docker pull hyperledger/fabric-ca:$ARCH-$FABRIC_IMG_TAG
docker pull hyperledger/fabric-ccenv:$ARCH-$FABRIC_IMG_TAG

echo "Done, now can startup the network using docker-compose..."

exit 0
