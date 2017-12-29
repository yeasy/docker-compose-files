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

BLOCK_FILE=${APP_CHANNEL}_config.block
echo_b "Convert the config block into json"
if [ -f ${BLOCK_FILE} ]; then
	configtxlatorDecode "common.Block" ${BLOCK_FILE} ${BLOCK_FILE}.json
	decode_result=$?
	echo_b "Parse config from payload..."
	[ ${decode_result} -eq 0 ] || exit
	jq "$PAYLOAD_CFG_PATH" ${BLOCK_FILE}.json > ${BLOCK_FILE}_payload_cfg.json

	echo_b "Add new org, generate updated_config.json"
	jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' ${BLOCK_FILE}_payload_cfg.json ./Org3MSP.json >& updated_config.json

	echo_b "Encode config and updated_config into protobuf"
	configtxlatorEncode "common.Config" ${BLOCK_FILE}_payload_cfg.json ${BLOCK_FILE}_payload_cfg.pb
	configtxlatorEncode "common.Config" updated_config.json updated_config.pb

	echo_b "Calculate the config delta protobuf"
	configtxlatorCompare ${APP_CHANNEL} ${BLOCK_FILE}_payload_cfg.pb updated_config.pb > org3_config_delta.pb

	echo_b "Decode the config delta protobuf into json"
	configtxlatorDecode "common.ConfigUpdate" org3_config_delta.pb org3_config_delta.json

	echo_b "Wrap the config update as envelope"
	echo '{"payload":{"header":{"channel_header":{"channel_id":"'"$APP_CHANNEL"'", "type":2}},"data":{"config_update":'$(cat org3_config_delta.json)'}}}' | jq . > org3_config_delta_envelope.json

	echo_b "Encode the config update into protobuf"
	configtxlatorEncode "common.Envelope" org3_config_delta_envelope.json org3_config_delta_envelope.pb

	echo_b "Sign the channel update tx by"
	exit
	#channelSignConfigTx ${APP_CHANNEL} "1" "0" org3_config_delta_envelope.pb
fi


echo_b "Stop configtxlator service"
docker rm -f $CTL_CONTAINER

echo_g "Test configtxlator for $MODE Passed"
