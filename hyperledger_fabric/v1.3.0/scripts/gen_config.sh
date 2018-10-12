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

[ ! -d ${CRYPTO_CONFIG} ] && mkdir -p ${CRYPTO_CONFIG}
[ ! -d org3/${CRYPTO_CONFIG} ] && mkdir -p org3/${CRYPTO_CONFIG}

echo_b "Make sure crypto-config dir exists already"
if [ ! -d ${CRYPTO_CONFIG} -o -z "$(ls -A ${CRYPTO_CONFIG})" ]; then # need to re-gen crypto
  echo_g "Path ${CRYPTO_CONFIG} not exists, re-generating it."

	docker run \
		--rm -it \
		--name ${GEN_CONTAINER} \
		-e "CONFIGTX_LOGGING_LEVEL=DEBUG" \
		-v $PWD/${CRYPTO_CONFIG}:/tmp/${CRYPTO_CONFIG} \
		-v $PWD/crypto-config.yaml:/tmp/crypto-config.yaml \
		-v $PWD/org3:/tmp/org3 \
		-v $PWD/scripts/gen_cryptoArtifacts.sh:/scripts/gen_cryptoArtifacts.sh \
		${GEN_IMG} sh -c 'sleep 1; bash /scripts/gen_cryptoArtifacts.sh'

		[ $? -ne 0 ] && exit 1
else
  echo_b "${CRYPTO_CONFIG} exists, ignore."
fi

cp -r org3/${CRYPTO_CONFIG}/* ${CRYPTO_CONFIG}/

[ ! -d ${MODE}/${CHANNEL_ARTIFACTS} ] && mkdir -p ${MODE}/${CHANNEL_ARTIFACTS}

echo_b "Make sure channel-artifacts dir exists already"
if [ ! -d ${MODE}/${CHANNEL_ARTIFACTS} -o -z "$(ls -A ${MODE}/${CHANNEL_ARTIFACTS})" ]; then
	echo_g "Path ${CHANNEL_ARTIFACTS} not exists, generating it."

#TODO: no need crypto-config path
	docker run \
		--rm -it \
		--name ${GEN_CONTAINER} \
		-e "CONFIGTX_LOGGING_LEVEL=DEBUG" \
		-v $PWD/${CRYPTO_CONFIG}:/tmp/${CRYPTO_CONFIG} \
		-v $PWD/${MODE}/configtx.yaml:/tmp/configtx.yaml \
		-v $PWD/${MODE}/${CHANNEL_ARTIFACTS}:/tmp/${CHANNEL_ARTIFACTS} \
		-v $PWD/org3:/tmp/org3 \
		-v $PWD/scripts/variables.sh:/scripts/variables.sh \
		-v $PWD/scripts/gen_channelArtifacts.sh:/scripts/gen_channelArtifacts.sh \
		${GEN_IMG} sh -c 'sleep 1; bash /scripts/gen_channelArtifacts.sh'

else
  echo_b "${CHANNEL_ARTIFACTS} exists, ignore."
fi

