#!/bin/bash
# Demo to use configtxlator to add some new organization
# Usage:
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

# clean env and exit
clean_exit() {
	echo_b "Stop configtxlator service"
	docker rm -f $CTL_CONTAINER
	exit 0
}

BLOCK_FILE=${APP_CHANNEL}_config.block
if [ ! -f ${BLOCK_FILE} ]; then
	echo_r "${BLOCK_FILE} not exist"
	clean_exit
fi

echo_b "Decode latest config block ${BLOCK_FILE} into json..."
configtxlatorDecode "common.Block" ${BLOCK_FILE} ${BLOCK_FILE}.json
[ $? -ne 0 ] && { echo_r "Decode ${BLOCK_FILE} failed"; clean_exit; }

echo_b "Parse config data from block payload and encode into pb..."
[ -f ${ORIGINAL_CFG_JSON} ] || jq "$PAYLOAD_CFG_PATH" ${BLOCK_FILE}.json > ${ORIGINAL_CFG_JSON}
jq . ${ORIGINAL_CFG_JSON} > /dev/null
[ $? -ne 0 ] && { echo_r "${ORIGINAL_CFG_JSON} is invalid"; clean_exit; }
configtxlatorEncode "common.Config" ${ORIGINAL_CFG_JSON} ${ORIGINAL_CFG_PB}

echo_b "Update the config with new org, and encode into pb"
[ -f ${UPDATED_CFG_JSON} ] || jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' ${ORIGINAL_CFG_JSON} ./Org3MSP.json >& ${UPDATED_CFG_JSON}
jq . ${UPDATED_CFG_JSON} > /dev/null
[ $? -ne 0 ] && { echo_r "${UPDATED_CFG_JSON} is invalid"; clean_exit; }
configtxlatorEncode "common.Config" ${UPDATED_CFG_JSON} ${UPDATED_CFG_PB}

echo_b "Calculate the config delta between pb files"
configtxlatorCompare ${APP_CHANNEL} ${ORIGINAL_CFG_PB} ${UPDATED_CFG_PB} ${CFG_DELTA_PB}

echo_b "Decode the config delta pb into json"
[ -f ${CFG_DELTA_JSON} ] || configtxlatorDecode "common.ConfigUpdate" ${CFG_DELTA_PB} ${CFG_DELTA_JSON}
jq . ${CFG_DELTA_JSON} > /dev/null
[ $? -ne 0 ] && { echo_r "${CFG_DELTA_JSON} is invalid"; clean_exit; }

echo_b "Wrap the config update as envelope"
[ -f ${CFG_DELTA_ENV_JSON} ] || echo '{"payload":{"header":{"channel_header":{"channel_id":"'"$APP_CHANNEL"'", "type":2}},"data":{"config_update":'$(cat ${CFG_DELTA_JSON})'}}}' | jq . > ${CFG_DELTA_ENV_JSON}

echo_b "Encode the config update envelope into pb"
configtxlatorEncode "common.Envelope" ${CFG_DELTA_ENV_JSON} ${CFG_DELTA_ENV_PB}

echo_g "Test configtxlator for $MODE Passed, now ready for peer to send the update transaction"

clean_exit