#!/usr/bin/env bash

ARCH=x86_64
BASEIMAGE_RELEASE=0.3.2
PROJECT_VERSION=1.0.2

# For testing 1.0.0 images
IMG_TAG=1.0.5

echo "Downloading images from DockerHub... need a while"

# TODO: we may need some checking on pulling result?
docker pull yeasy/hyperledger-fabric-base:$IMG_TAG \
  && docker pull yeasy/hyperledger-fabric-peer:$IMG_TAG \
  && docker pull yeasy/hyperledger-fabric-orderer:$IMG_TAG \
  && docker pull yeasy/hyperledger-fabric-ca:$IMG_TAG \
  && docker pull hyperledger/fabric-couchdb:$ARCH-$IMG_TAG \
  && docker pull hyperledger/fabric-kafka:$ARCH-$IMG_TAG \
  && docker pull hyperledger/fabric-zookeeper:$ARCH-$IMG_TAG

# Only useful for debugging
# docker pull yeasy/hyperledger-fabric

echo "===Pulling fabric images from official repo... with tag = ${IMG_TAG}"
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

echo "Done, now can startup the network using docker-compose..."

exit 0
