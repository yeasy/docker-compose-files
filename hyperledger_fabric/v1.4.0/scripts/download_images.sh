#!/usr/bin/env bash

# Define those global variables
if [ -f ./variables.sh ]; then
 source ./variables.sh
elif [ -f scripts/variables.sh ]; then
 source scripts/variables.sh
else
	echo_r "Cannot find the variables.sh files, pls check"
	exit 1
fi

pull_image() {
	IMG=$1
	#if [ -z "$(docker images -q ${IMG} 2> /dev/null)" ]; then  # not exist
	#	docker pull ${IMG}
	#else
 	# echo "${IMG} already exist locally"
	#fi
	docker pull ${IMG}
}

echo "Downloading images from DockerHub... need a while"

# TODO: we may need some checking on pulling result?
echo "=== Pulling yeasy/hyperledger-fabric-* images with tag ${FABRIC_IMG_TAG}... ==="
for IMG in base peer orderer ca; do
	pull_image yeasy/hyperledger-fabric-${IMG}:$FABRIC_IMG_TAG &
done

pull_image yeasy/hyperledger-fabric:$FABRIC_IMG_TAG
pull_image yeasy/blockchain-explorer:0.1.0-preview  # TODO: wait for official images


echo "=== Pulling base images ${BASE_IMG_TAG} from fabric repo... ==="
for IMG in baseimage baseos couchdb kafka zookeeper; do
	HLF_IMG=hyperledger/fabric-${IMG}:$ARCH-$BASE_IMG_TAG
	pull_image $HLF_IMG
done

# TODO: official core.yaml still use PROJECT_VERSION for fabric-baseos, however, dockerhub does not have the version
docker tag hyperledger/fabric-baseos:$ARCH-$BASE_IMG_TAG hyperledger/fabric-baseos:$FABRIC_IMG_TAG

# Only useful for debugging
# docker pull yeasy/hyperledger-fabric

echo "=== Pulling fabric images ${FABRIC_IMG_TAG} from fabric repo... ==="
for IMG in peer tools orderer ca ccenv tools; do
	if [ "$FABRIC_IMG_TAG" == "latest" ]; then
		HLF_IMG=hyperledger/fabric-${IMG}:$FABRIC_IMG_TAG
	else
		HLF_IMG=hyperledger/fabric-${IMG}:$ARCH-$FABRIC_IMG_TAG
	fi
	pull_image $HLF_IMG
done

echo "Image pulling done, now can startup the network using docker-compose..."

exit 0
