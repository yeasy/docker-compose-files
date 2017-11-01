#!/bin/bash
# More details about configtxlator, see http://hlf.readthedocs.io/en/latest/configtxlator.html

CONFIGTXLATOR_IMG=yeasy/hyperledger-fabric:latest
CONFIGTXLATOR_CONTAINER=configtxlator

ARTIFACTS_DIR=channel-artifacts

ORDERER_GENESIS_BLOCK=${ARTIFACTS_DIR}/orderer.genesis.block
ORDERER_GENESIS_UPDATED_BLOCK=${ARTIFACTS_DIR}/orderer.genesis.updated.block
ORDERER_GENESIS_JSON=${ARTIFACTS_DIR}/orderer.genesis.json
ORDERER_GENESIS_UPDATED_JSON=${ARTIFACTS_DIR}/orderer.genesis.updated.json
MAXBATCHSIZEPATH=".data.data[0].payload.data.config.channel_group.groups.Orderer.values.BatchSize.value.max_message_count"

echo "Clean potential existing container $CONFIGTXLATOR_CONTAINER"
[ "$(docker ps -a | grep $CONFIGTXLATOR_CONTAINER)" ] && docker rm -f $CONFIGTXLATOR_CONTAINER

echo "Start configtxlator service and listen on port 7059"
docker run \
	-d -it \
	--name ${CONFIGTXLATOR_CONTAINER} \
	-p 127.0.0.1:7059:7059 \
	${CONFIGTXLATOR_IMG} \
	configtxlator start

sleep 1

if [ -f ${ORDERER_GENESIS_BLOCK} ]; then
	echo "Decoding the orderer genesis block to json"
	curl -X POST \
		--data-binary @${ORDERER_GENESIS_BLOCK} \
		http://127.0.0.1:7059/protolator/decode/common.Block \
		> ${ORDERER_GENESIS_JSON}

	echo "Checking existing Orderer.BatchSize.max_message_count in the genesis json"
	jq "$MAXBATCHSIZEPATH" channel-artifacts/orderer.genesis.json

	echo "Creating new genesis json with updated Orderer.BatchSize.max_message_count"
	jq "$MAXBATCHSIZEPATH=20" ${ORDERER_GENESIS_JSON} > ${ORDERER_GENESIS_UPDATED_JSON}

	echo "Re-Encoding the orderer genesis json to block"
	curl -X POST \
		--data-binary @${ORDERER_GENESIS_UPDATED_JSON} \
		http://127.0.0.1:7059/protolator/encode/common.Block \
		>${ORDERER_GENESIS_UPDATED_BLOCK}
fi

for i in {0..9}
do
	BLOCK_FILE=${ARTIFACTS_DIR}/block_${i}.block
	if [ -f ${BLOCK_FILE} ]; then
		echo "Decoding block $i of app channel to json"
		curl -X POST \
			--data-binary @${BLOCK_FILE} \
			http://127.0.0.1:7059/protolator/decode/common.Block \
			> ${BLOCK_FILE}.json
		fi
done

docker rm -f $CONFIGTXLATOR_CONTAINER
