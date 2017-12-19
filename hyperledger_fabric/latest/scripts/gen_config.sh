#! /bin/bash
# Generating
#  * crypto-config/*
#  * channel-artifacts
#    * orderer.genesis.block
#    * channel.tx
#    * Org1MSPanchors.tx
#    * Org2MSPanchors.tx

if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
else
	echo "Cannot find the func.sh files, pls check"
	exit 1
fi

[ $# -ne 1 ] && echo_r "[Usage] $0 solo|kafka" && exit 1 || MODE=$1

echo_b "Generating artifacts for ${MODE}"

echo_b "Clean existing container $GEN_CONTAINER"
[ "$(docker ps -a | grep $GEN_CONTAINER)" ] && docker rm -f $GEN_CONTAINER

pushd ${MODE}

echo_b "Check whether crypto-config exist already"
GEN_CRYPTO=true
if [ -d ${CRYPTO_CONFIG} ]; then # already exist, no need to re-gen crypto
  echo_b "${CRYPTO_CONFIG} existed, won't regenerate it."
  GEN_CRYPTO=false
else
  echo_b "${CRYPTO_CONFIG} not exists, generate later."
	mkdir -p ${CRYPTO_CONFIG}
fi

echo_b "Make sure channel-artifacts dir exists already"
if [ ! -d ${CHANNEL_ARTIFACTS} ]; then
	echo_b "${CHANNEL_ARTIFACTS} not exists, create it."
	mkdir -p ${CHANNEL_ARTIFACTS}
fi

echo_b "Starting container $GEN_CONTAINER in background"
docker run \
	-d -it \
	--name $GEN_CONTAINER \
	-e "CONFIGTX_LOGGING_LEVEL=DEBUG" \
	-e "CONFIGTX_LOGGING_FORMAT=%{color}[%{id:03x} %{time:01-02 15:04:05.00 MST}] [%{longpkg}] %{callpath} -> %{level:.4s}%{color:reset} %{message}" \
	-v $PWD/configtx.yaml:${FABRIC_CFG_PATH}/configtx.yaml \
	-v $PWD/crypto-config.yaml:${FABRIC_CFG_PATH}/crypto-config.yaml \
	-v $PWD/${CRYPTO_CONFIG}:${FABRIC_CFG_PATH}/${CRYPTO_CONFIG} \
	-v $PWD/${CHANNEL_ARTIFACTS}:/tmp/${CHANNEL_ARTIFACTS} \
	${GEN_IMG} bash -c 'while true; do sleep 20171001; done'

if [ "${GEN_CRYPTO}" = "true" ]; then
	echo_b "Generating crypto-config"
	gen_con_exec cryptogen generate --config=$FABRIC_CFG_PATH/crypto-config.yaml --output ${FABRIC_CFG_PATH}/${CRYPTO_CONFIG}
fi

echo_b "Generate genesis block for system channel using configtx.yaml"
[ -f ${CHANNEL_ARTIFACTS}/${ORDERER_GENESIS} ] || gen_con_exec configtxgen -profile ${ORDERER_PROFILE} -outputBlock /tmp/${CHANNEL_ARTIFACTS}/${ORDERER_GENESIS}

echo_b "Create the new app channel tx using configtx.yaml"
[ -f ${CHANNEL_ARTIFACTS}/${APP_CHANNEL_TX} ] || gen_con_exec configtxgen -profile TwoOrgsChannel -outputCreateChannelTx /tmp/$CHANNEL_ARTIFACTS/${APP_CHANNEL_TX} -channelID ${APP_CHANNEL}
gen_con_exec bash -c "configtxgen -inspectChannelCreateTx /tmp/${CHANNEL_ARTIFACTS}/${APP_CHANNEL_TX} > /tmp/${CHANNEL_ARTIFACTS}/${APP_CHANNEL_TX}.json"

echo_b "Create the anchor peer configuration tx using configtx.yaml"
[ -f ${CHANNEL_ARTIFACTS}/${UPDATE_ANCHOR_ORG1_TX} ] || gen_con_exec configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate /tmp/${CHANNEL_ARTIFACTS}/${UPDATE_ANCHOR_ORG1_TX} -channelID ${APP_CHANNEL} -asOrg Org1MSP
[ -f ${CHANNEL_ARTIFACTS}/${UPDATE_ANCHOR_ORG2_TX} ] || gen_con_exec configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate /tmp/${CHANNEL_ARTIFACTS}/${UPDATE_ANCHOR_ORG2_TX} -channelID ${APP_CHANNEL} -asOrg Org2MSP

echo_b "Remove the container $GEN_CONTAINER" && docker rm -f $GEN_CONTAINER

echo_g "Generated artifacts for ${MODE}"

