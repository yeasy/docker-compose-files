#! /bin/bash
# Generating
#  * crypto-config
#  * channel-artifacts
#    * orderer.genesis.block
#    * channel.tx
#    * Org1MSPanchors.tx
#    * Org2MSPanchors.tx


[ $# -ne 1 ] && echo_b "Need config path as param" && exit 1
MODE=$1


# Run cmd inside the container
con_exec() {
	docker exec -it $GEN_CONTAINER "$@"
}

if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "Generating artifacts in ${MODE}"

echo_b "Clean existing container $GEN_CONTAINER"
[ "$(docker ps -a | grep $GEN_CONTAINER)" ] && docker rm -f $GEN_CONTAINER

pushd ${MODE}

echo_b "Check whether channel-artifacts or crypto-config exist already"
[ -d ${CRYPTO_CONFIG} ] && echo "${CRYPTO_CONFIG} existed, will stop generating new configs" && exit 0
mkdir ${CRYPTO_CONFIG}
[ -d ${CHANNEL_ARTIFACTS} ] && echo "${CHANNEL_ARTIFACTS} existed, will stop generating new configs" && exit 0
mkdir ${CHANNEL_ARTIFACTS}

echo_b "Starting container $GEN_CONTAINER in background"
docker run \
	-d -it \
	--name $GEN_CONTAINER \
	-v $PWD/${CRYPTO_CONFIG}:${FABRIC_CFG_PATH}/${CRYPTO_CONFIG} \
	-v $PWD/${CHANNEL_ARTIFACTS}:/tmp/${CHANNEL_ARTIFACTS} \
	$GEN_IMG bash -c 'while true; do sleep 20171001; done'

echo_b "Generating crypto-config"
con_exec cryptogen generate --config=$FABRIC_CFG_PATH/crypto-config.yaml --output ${FABRIC_CFG_PATH}/crypto-config

echo_b "Generate genesis block file for system channel using configtx.yaml"
con_exec configtxgen -profile TwoOrgsOrdererGenesis -outputBlock /tmp/${CHANNEL_ARTIFACTS}/${ORDERER_GENESIS}

echo_b "Create the new app channel tx using configtx.yaml"
con_exec configtxgen -profile TwoOrgsChannel -outputCreateChannelTx /tmp/$CHANNEL_ARTIFACTS/channel.tx -channelID ${APP_CHANNEL}

echo_b "Create the anchor peer configuration tx using configtx.yaml"
con_exec configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate /tmp/${CHANNEL_ARTIFACTS}/Org1MSPanchors.tx -channelID ${APP_CHANNEL} -asOrg Org1MSP
con_exec configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate /tmp/${CHANNEL_ARTIFACTS}/Org2MSPanchors.tx -channelID ${APP_CHANNEL} -asOrg Org2MSP

echo_b "Remove the container $GEN_CONTAINER" && docker rm -f $GEN_CONTAINER

echo_g "Generated artifacts in ${MODE}"
