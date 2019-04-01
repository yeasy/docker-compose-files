#! /bin/bash
# Generating
#  * crypto-config/*

if [ -f ./func.sh ]; then
	source ./func.sh
elif [ -f scripts/func.sh ]; then
	source scripts/func.sh
else
	echo "Cannot find the func.sh files, pls check"
	exit 1
fi

echo_b "Clean existing container $GEN_CONTAINER"
[ "$(docker ps -a | grep $GEN_CONTAINER)" ] && docker rm -f $GEN_CONTAINER

[ ! -d ${CRYPTO_CONFIG} ] && mkdir -p ${CRYPTO_CONFIG}
[ ! -d org3/${CRYPTO_CONFIG} ] && mkdir -p org3/${CRYPTO_CONFIG}

echo_b "Make sure crypto-config dir exists already"
if [ -d ${CRYPTO_CONFIG} -a ! -z "$(ls -A ${CRYPTO_CONFIG})" ]; then # No need to regen
	echo_b "${CRYPTO_CONFIG} exists, ignore."
	exit 0
fi

echo_g "Generating ${CRYPTO_CONFIG}..."
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

echo_b "Copy org3's crypto config outside"
cp -r org3/${CRYPTO_CONFIG}/* ${CRYPTO_CONFIG}/

echo_g "Generate crypto configs with $0 done"