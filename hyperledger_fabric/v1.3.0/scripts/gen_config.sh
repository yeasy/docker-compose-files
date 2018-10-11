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

echo_b "Make sure crypto-config dir exists already"
if [ ! -d ${CRYPTO_CONFIG} ]; then # already exist, no need to re-gen crypto
  echo_g "Path ${CRYPTO_CONFIG} not exists, re-generating it."
  echo_b "Path org3/crypto-config will keep unchanged by default if exists."
	mkdir -p ${CRYPTO_CONFIG}

	docker run \
		--rm -it \
		--name ${GEN_CONTAINER} \
		-e "CONFIGTX_LOGGING_LEVEL=DEBUG" \
		-e "CONFIGTX_LOGGING_FORMAT=%{color}[%{id:03x} %{time:01-02 15:04:05.00 MST}] [%{longpkg}] %{callpath} -> %{level:.4s}%{color:reset} %{message}" \
		-v $PWD/scripts/variables.sh:/tmp/variables.sh \
		-v $PWD/crypto-config.yaml:/tmp/crypto-config.yaml \
		-v $PWD/${CRYPTO_CONFIG}:${FABRIC_CFG_PATH}/${CRYPTO_CONFIG} \
		-v $PWD/scripts/gen_cryptoArtifacts.sh:/tmp/gen_cryptoArtifacts.sh \
		-v $PWD/org3:/tmp/org3 \
		${GEN_IMG} bash -c 'bash /tmp/gen_cryptoArtifacts.sh'
else
  echo_b "${CRYPTO_CONFIG} exists, ignore."
fi

echo_b "Make sure channel-artifacts dir exists already"
if [ ! -d ${MODE}/${CHANNEL_ARTIFACTS} ]; then
	echo_g "Path ${CHANNEL_ARTIFACTS} not exists, generating it."
	mkdir -p ${MODE}/${CHANNEL_ARTIFACTS}

	docker run \
		--rm -it \
		--name ${GEN_CONTAINER} \
		-e "CONFIGTX_LOGGING_LEVEL=DEBUG" \
		-e "CONFIGTX_LOGGING_FORMAT=%{color}[%{id:03x} %{time:01-02 15:04:05.00 MST}] [%{longpkg}] %{callpath} -> %{level:.4s}%{color:reset} %{message}" \
		-v $PWD/scripts/variables.sh:/tmp/variables.sh \
		-v $PWD/${CRYPTO_CONFIG}:${FABRIC_CFG_PATH}/${CRYPTO_CONFIG} \
		-v $PWD/${MODE}/configtx.yaml:${FABRIC_CFG_PATH}/configtx.yaml \
		-v $PWD/${MODE}/${CHANNEL_ARTIFACTS}:/tmp/${CHANNEL_ARTIFACTS} \
		-v $PWD/scripts/gen_channelArtifacts.sh:/tmp/gen_channelArtifacts.sh \
		-v $PWD/org3:/tmp/org3 \
		${GEN_IMG} bash -c 'bash /tmp/gen_channelArtifacts.sh'

else
  echo_b "${CHANNEL_ARTIFACTS} exists, ignore."
fi

