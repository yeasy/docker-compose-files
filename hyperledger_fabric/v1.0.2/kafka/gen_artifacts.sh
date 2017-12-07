#! /bin/bash

GEN_IMG=yeasy/hyperledger-fabric:1.0.2
GEN_CONTAINER=generator
CFG_DIR=/etc/hyperledger/fabric
TMP_DIR=/tmp
ARTIFACTS_DIR=$TMP_DIR/channel-artifacts
CHANNEL_NAME=businesschannel

echo "Clean potential existing container $GEN_CONTAINER"
[ "$(docker ps -a | grep $GEN_CONTAINER)" ] && docker rm -f $GEN_CONTAINER

echo "Remove existing artifacts"
rm -rf crypto-config channel-artifacts

echo "Starting container $GEN_CONTAINER in background"
docker run \
	-d -it \
	--name $GEN_CONTAINER \
	$GEN_IMG bash -c 'while true; do sleep 20171001; done'

echo "Create the $ARTIFACTS_DIR path"
docker exec -it $GEN_CONTAINER \
	mkdir -p $ARTIFACTS_DIR

echo "Copy crypto-config.yaml and configtx.yaml into $GEN_CONTAINER:/tmp"
docker cp ./crypto-config.yaml $GEN_CONTAINER:$CFG_DIR
docker cp ./configtx.yaml $GEN_CONTAINER:$CFG_DIR

echo "Generating crypto-config and export"
docker exec -it $GEN_CONTAINER \
	cryptogen generate --config=$CFG_DIR/crypto-config.yaml --output $TMP_DIR/crypto-config
echo "Export crypto-config to local"
docker cp $GEN_CONTAINER:$TMP_DIR/crypto-config ./

echo "Copy crypto-config to the config path"
docker exec -it $GEN_CONTAINER \
	cp -r $TMP_DIR/crypto-config $CFG_DIR

echo "Generating orderer genesis block file"
docker exec -it $GEN_CONTAINER \
	configtxgen -profile TwoOrgsOrdererGenesis -outputBlock $ARTIFACTS_DIR/orderer.genesis.block

echo "Create the new application channel tx"
docker exec -it $GEN_CONTAINER \
	configtxgen -profile TwoOrgsChannel -outputCreateChannelTx $ARTIFACTS_DIR/channel.tx -channelID ${CHANNEL_NAME}

echo "Creating the anchor peer configuration tx"
docker exec -it $GEN_CONTAINER \
	configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate $ARTIFACTS_DIR/Org1MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org1MSP
docker exec -it $GEN_CONTAINER \
	configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate $ARTIFACTS_DIR/Org2MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org2MSP

echo "Export $ARTIFACTS_DIR to local"
docker cp $GEN_CONTAINER:$ARTIFACTS_DIR ./

echo "Remove the container $GEN_CONTAINER"
docker rm -f $GEN_CONTAINER