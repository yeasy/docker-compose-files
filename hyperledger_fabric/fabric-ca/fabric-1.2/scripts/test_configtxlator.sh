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

[ $# -ne 1 ] && echo_r "Usage: bash test_configtxlator solo|kafka" && exit 1

MODE=$1

pushd $MODE/${CHANNEL_ARTIFACTS}

# Must run `make gen_config` to generate config files first


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

echo_b "Convert all config block files into json"
for BLOCK_FILE in *.block; do
	[ -f ${BLOCK_FILE}.json ] || configtxlatorDecode "common.Block" ${BLOCK_FILE} ${BLOCK_FILE}.json
	decode_result=$?
	#echo_b "Parse payload..."
	#[ ${decode_result} -eq 0 ] && jq "$PAYLOAD_PATH" ${BLOCK_FILE}.json > ${BLOCK_FILE}_payload.json
done

echo_b "Update the content of orderer genesis file"
if [ -f ${ORDERER_GENESIS} ]; then
	echo_b "Checking existing Orderer.BatchSize.max_message_count in the genesis json"
	jq "$MAX_BATCH_SIZE_PATH" ${ORDERER_GENESIS_JSON}

	echo_b "Creating new genesis json with updated Orderer.BatchSize.max_message_count"
	jq "$MAX_BATCH_SIZE_PATH=20" ${ORDERER_GENESIS_JSON} > ${ORDERER_GENESIS_UPDATED_JSON}

	echo_b "Re-Encoding the orderer genesis json to block"
	configtxlatorEncode "common.Block" ${ORDERER_GENESIS_UPDATED_JSON} ${ORDERER_GENESIS_UPDATED_BLOCK}
fi

echo_b "Stop configtxlator service"
docker rm -f $CTL_CONTAINER

echo_g "Test configtxlator for $MODE Passed"
