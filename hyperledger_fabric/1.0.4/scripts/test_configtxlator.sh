#!/bin/bash
# Demo to use configtxlator to modify orderer config
# Usage: bash test_configtxlator solo|kafka
# Configtxlator APIs:
	# Json -> ProtoBuf: http://$SERVER:$PORT/protolator/encode/<message.Name>
	# ProtoBuf -> Json: http://$SERVER:$PORT/protolator/decode/<message.Name>
	# Compute Update: http://$SERVER:$PORT/configtxlator/compute/update-from-configs
# <message.Name> could be: common.Block, common.Envelope, common.ConfigEnvelope, common.ConfigUpdateEnvelope, common.Config, common.ConfigUpdate
# More details about configtxlator, see http://hlf.readthedocs.io/en/latest/configtxlator.html

if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

if [ $# -ne 1 ]; then
	echo_r "Usage: bash test_configtxlator solo|kafka"
else
	mode=$1
fi

CTL_IMG=yeasy/hyperledger-fabric:1.0.4
CTL_CONTAINER=configtxlator

# Must run `make gen_kafka` and `make gen_solo` to generate artifacts files first
ARTIFACTS_DIR=$mode/channel-artifacts

ORDERER_GENESIS_BLOCK=${ARTIFACTS_DIR}/orderer.genesis.block
ORDERER_GENESIS_JSON=${ARTIFACTS_DIR}/orderer.genesis.block.json
ORDERER_GENESIS_UPDATED_BLOCK=${ARTIFACTS_DIR}/orderer.genesis.updated.block
ORDERER_GENESIS_UPDATED_JSON=${ARTIFACTS_DIR}/orderer.genesis.updated.json
MAXBATCHSIZEPATH=".data.data[0].payload.data.config.channel_group.groups.Orderer.values.BatchSize.value.max_message_count"

echo_b "Clean potential existing container $CTL_CONTAINER"
[ "$(docker ps -a | grep $CTL_CONTAINER)" ] && docker rm -f $CTL_CONTAINER

echo_b "Start configtxlator service in background (listen on port 7059)"
docker run \
	-d -it \
	--name ${CTL_CONTAINER} \
	-p 127.0.0.1:7059:7059 \
	${CTL_IMG} \
	configtxlator start --port=7059

sleep 1

echo_b "Convert all block files into json"
for BLOCK_FILE in ${ARTIFACTS_DIR}/*.block; do
	if [ -f ${BLOCK_FILE} ]; then
		echo_b "Decoding all block file ${BLOCK_FILE} to json"
		curl -X POST \
			--data-binary @${BLOCK_FILE} \
			http://127.0.0.1:7059/protolator/decode/common.Block \
			> ${BLOCK_FILE}.json
		fi
done

if [ -f ${ORDERER_GENESIS_BLOCK} ]; then
	echo_b "Checking existing Orderer.BatchSize.max_message_count in the genesis json"
	jq "$MAXBATCHSIZEPATH" channel-artifacts/orderer.genesis.json

	echo_b "Creating new genesis json with updated Orderer.BatchSize.max_message_count"
	jq "$MAXBATCHSIZEPATH=20" ${ORDERER_GENESIS_JSON} > ${ORDERER_GENESIS_UPDATED_JSON}

	echo_b "Re-Encoding the orderer genesis json to block"
	configtxlatorEncode "common.Block" ${ORDERER_GENESIS_UPDATED_JSON} ${ORDERER_GENESIS_UPDATED_BLOCK}
fi

echo_b "Stop configtxlator service"
docker rm -f $CTL_CONTAINER

echo_g "Test configtxlator on $mode Passed"
