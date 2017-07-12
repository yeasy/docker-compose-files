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

ARCH=x86_64
BASEIMAGE_RELEASE=0.3.1
BASE_VERSION=1.0.0
PROJECT_VERSION=1.0.0

# For testing 1.0.0 images
IMG_VERSION=1.0.0

echo_b "Downloading images from DockerHub... need a while"

# TODO: we may need some checking on pulling result?
docker pull yeasy/hyperledger-fabric-base:$IMG_VERSION \
  && docker pull yeasy/hyperledger-fabric-peer:$IMG_VERSION \
  && docker pull yeasy/hyperledger-fabric-orderer:$IMG_VERSION \
  && docker pull yeasy/hyperledger-fabric-ca:$IMG_VERSION \
  && docker pull hyperledger/fabric-couchdb:$ARCH-$IMG_VERSION \
  && docker pull hyperledger/fabric-kafka:$ARCH-$IMG_VERSION \
  && docker pull hyperledger/fabric-zookeeper:$ARCH-$IMG_VERSION

# Only useful for debugging
# docker pull yeasy/hyperledger-fabric

echo_b "Rename images with official tags..."
docker tag yeasy/hyperledger-fabric-peer:$IMG_VERSION hyperledger/fabric-peer \
  && docker tag yeasy/hyperledger-fabric-peer:$IMG_VERSION hyperledger/fabric-tools \
  && docker tag yeasy/hyperledger-fabric-orderer:$IMG_VERSION hyperledger/fabric-orderer \
  && docker tag yeasy/hyperledger-fabric-ca:$IMG_VERSION hyperledger/fabric-ca \
  && docker tag yeasy/hyperledger-fabric-base:$IMG_VERSION hyperledger/fabric-ccenv:$ARCH-$PROJECT_VERSION \
  && docker tag yeasy/hyperledger-fabric-base:$IMG_VERSION hyperledger/fabric-baseos:$ARCH-$BASEIMAGE_RELEASE \
  && docker tag yeasy/hyperledger-fabric-base:$IMG_VERSION hyperledger/fabric-baseimage:$ARCH-$BASEIMAGE_RELEASE \
  && docker tag hyperledger/fabric-zookeeper:$ARCH-$IMG_VERSION hyperledger/fabric-zookeeper \
  && docker tag hyperledger/fabric-kafka:$ARCH-$IMG_VERSION hyperledger/fabric-kafka

echo_g "Done, now can startup the network using docker-compose..."
