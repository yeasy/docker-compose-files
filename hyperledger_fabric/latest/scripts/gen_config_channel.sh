#! /bin/bash
# Generating
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

echo_b "Generating channel artifacts with ${GEN_IMG} in mode ${MODE}"

[ ! -d ${MODE}/${CHANNEL_ARTIFACTS} ] && mkdir -p ${MODE}/${CHANNEL_ARTIFACTS}

echo_b "Make sure channel-artifacts dir exists already"
if [ -d ${MODE}/${CHANNEL_ARTIFACTS} -a ! -z "$(ls -A ${MODE}/${CHANNEL_ARTIFACTS})" ]; then
	echo_b "${CHANNEL_ARTIFACTS} exists, ignore."
	exit 0
fi

echo_g "Generating ${CHANNEL_ARTIFACTS}..."
docker run \
	--rm -it \
	--name ${GEN_CONTAINER} \
	-e "FABRIC_LOGGING_SPEC=common.tools.configtxgen=DEBUG:INFO" \
	-v $PWD/${CRYPTO_CONFIG}:/tmp/${CRYPTO_CONFIG} \
	-v $PWD/${MODE}/configtx.yaml:/tmp/configtx.yaml \
	-v $PWD/${MODE}/${CHANNEL_ARTIFACTS}:/tmp/${CHANNEL_ARTIFACTS} \
	-v $PWD/org3:/tmp/org3 \
	-v $PWD/scripts/variables.sh:/scripts/variables.sh \
	-v $PWD/scripts/gen_channelArtifacts.sh:/scripts/gen_channelArtifacts.sh \
	${GEN_IMG} sh -c 'sleep 1; bash /scripts/gen_channelArtifacts.sh'
[ $? -ne 0 ] && exit 1

echo_g "Generate channel artifacts with $0 done"
