#!/usr/bin/env bash

# peer/orderer/ca/ccenv/tools/javaenv/baseos: 1.4, 1.4.0, 1.4.1, 2.0.0, latest
# baseimage (runtime for golang chaincode) and couchdb: 0.4.18, latest

# In core.yaml, it requires:
# * fabric-ccenv:$(TWO_DIGIT_VERSION)
# * fabric-baseos:$(TWO_DIGIT_VERSION)
# * fabric-javaenv:$(TWO_DIGIT_VERSION)
# * fabric-nodeenv:$(TWO_DIGIT_VERSION)

# Define those global variables
if [ -f ./variables.sh ]; then
  source ./variables.sh
elif [ -f scripts/variables.sh ]; then
  source scripts/variables.sh
else
  echo_r "Cannot find the variables.sh files, pls check"
  exit 1
fi

# pull_image image_name <true|false (default)>
pull_image() {
  IMG=$1
  FORCED="false"
  if [ "$#" -eq 2 ]; then
    FORCED=$2
  fi
  if [ ! -z "$(docker images -q ${IMG} 2>/dev/null)" ] && [ "$FORCED" != "true" ]; then # existed and not forced to update
    echo "${IMG} already exists and not forced to update "
  else
    docker pull ${IMG}
  fi
}

echo "Downloading images from DockerHub... need a while"

# TODO: we may need some checking on pulling result?
echo "=== Pulling yeasy/hyperledger-fabric-*:${FABRIC_IMG_TAG} images... ==="
for IMG in base peer orderer ca; do
  pull_image "yeasy/hyperledger-fabric-${IMG}:$FABRIC_IMG_TAG" "true" &
done

pull_image yeasy/hyperledger-fabric:$FABRIC_IMG_TAG "true"

# pull_image yeasy/blockchain-explorer:0.1.0-preview  # TODO: wait for official images
#echo "=== Pulling fabric core images ${FABRIC_IMG_TAG} from fabric repo... ==="
#for IMG in peer orderer ca tools; do
#	pull_image hyperledger/fabric-${IMG}:$FABRIC_IMG_TAG & # e.g., v2.3.0
#done

echo "=== Pulling fabric chaincode images ${TWO_DIGIT_VERSION} from fabric repo... ==="
for IMG in ccenv baseos javaenv nodeenv; do
  pull_image hyperledger/fabric-${IMG}:${TWO_DIGIT_VERSION} & # e.g., v2.2
done

# TODO: dockerhub fabric-ccenv:2.0 image is too old
# Hence we need to build the image locally and tag it manually
docker tag yeasy/hyperledger-fabric-base hyperledger/fabric-ccenv:${TWO_DIGIT_VERSION}

echo "Image pulling done, now can startup the network using make start..."
exit 0
