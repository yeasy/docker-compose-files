#!/bin/bash

echo "===Download official images from https://hub.docker.com/u/hyperledger/"

# pull fabric images
ARCH=x86_64
BASEIMAGE_RELEASE=0.3.1
PROJECT_VERSION=1.0.0
IMG_TAG=1.0.0

echo "===Pulling fabric images... with tag = ${IMG_TAG}"
docker pull hyperledger/fabric-peer:$ARCH-$IMG_TAG
docker pull hyperledger/fabric-tools:$ARCH-$IMG_TAG
docker pull hyperledger/fabric-orderer:$ARCH-$IMG_TAG
docker pull hyperledger/fabric-ca:$ARCH-$IMG_TAG
docker pull hyperledger/fabric-ccenv:$ARCH-$IMG_TAG
docker pull hyperledger/fabric-baseimage:$ARCH-$BASEIMAGE_RELEASE
docker pull hyperledger/fabric-baseos:$ARCH-$BASEIMAGE_RELEASE

echo "===Re-tagging images to *latest* tag"
docker tag hyperledger/fabric-peer:$ARCH-$IMG_TAG hyperledger/fabric-peer
docker tag hyperledger/fabric-tools:$ARCH-$IMG_TAG hyperledger/fabric-tools
docker tag hyperledger/fabric-orderer:$ARCH-$IMG_TAG hyperledger/fabric-orderer
docker tag hyperledger/fabric-ca:$ARCH-$IMG_TAG hyperledger/fabric-ca

echo_g "Done, now can startup the network using docker-compose..."
