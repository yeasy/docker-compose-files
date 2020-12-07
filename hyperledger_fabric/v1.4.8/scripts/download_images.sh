#!/usr/bin/env bash

# peer/orderer/ca/ccenv/tools/javaenv/baseos: 1.4, 1.4.0, 1.4.1, 2.0.0, latest
# baseimage (runtime for golang chaincode)/couchdb: 0.4.15, latest
# Noted:
# * the fabric-baseos 1.4/2.0 tags are not available at dockerhub yet, only latest/0.4.15 now
# * the fabric-nodeenv is not available at dockerhub yet

# In core.yaml, it requires:
# * fabric-ccenv:$(PROJECT_VERSION)
# * fabric-baseos:$(PROJECT_VERSION)
# * fabric-javaenv:latest
# * fabric-nodeenv:latest

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
	if [ ! -z "$(docker images -q ${IMG} 2> /dev/null)" ] && [ "$FORCED" != "true" ]; then  # existed and not forced to update
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

pull_image yeasy/hyperledger-fabric:$FABRIC_IMG_TAG

# pull_image yeasy/blockchain-explorer:0.1.0-preview  # TODO: wait for official images
echo "=== Pulling fabric core images ${FABRIC_IMG_TAG} from fabric repo... ==="
for IMG in peer orderer ca ccenv tools baseos javaenv nodeenv; do
	pull_image hyperledger/fabric-${IMG}:$FABRIC_IMG_TAG & # e.g., v1.4.4
done

# core.yaml requires a PROJECT_VERSION tag, only need when testing latest code
docker tag hyperledger/fabric-ccenv:$FABRIC_IMG_TAG hyperledger/fabric-ccenv:${PROJECT_VERSION}

echo "=== Pulling base/3rd-party images with tag ${BASE_IMG_TAG} from fabric repo... ==="
for IMG in baseimage baseos couchdb kafka zookeeper; do
	pull_image hyperledger/fabric-${IMG}:$BASE_IMG_TAG &  # e.g., 0.4.18
done

if [ ${PROJECT_VERSION} == "2.0.0" ]; then
  pull_image hyperledger/fabric-javaenv:latest # core.yaml requires a latest tag
  # core.yaml requires a latest tag, but nodeenv is not available in docker hub yet
  # pull_image hyperledger/fabric-nodeenv:latest
  pull_image hyperledger/fabric-baseos:latest # fabric-baseos does not have 1.4/2.0 tag yet, but core.yaml requires a PROJECT_VERSION tag
  docker tag hyperledger/fabric-baseos:latest hyperledger/fabric-baseos:${PROJECT_VERSION}
fi

echo "Image pulling done, now can startup the network using make start..."

exit 0