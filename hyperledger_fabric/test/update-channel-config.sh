#!/bin/bash

# This script will fix every channel's orderer admin policy from implicit to signature based.

# Usage: TODO

# changed the policy:
#Admins:
#            Type: ImplicitMeta
#            Rule: "MAJORITY Admins"

#-->

#Admins:
#            Type: Signature
#            Rule: "OR('{{.ORGNAME}}.admin')"


# configtxlator encode json to pb
# Usage: configtxlatorEncode msgType input output
configtxlatorEncode() {
  msgType=$1
  input=$2
  output=$3

  echo "Encode $input --> $output using type $msgType"
  configtxlator proto_encode \
    --type=${msgType} \
    --input=${input} \
    --output=${output}
}

# configtxlator decode pb to json
# Usage: configtxlatorEncode msgType input output
configtxlatorDecode() {
  msgType=$1
  input=$2
  output=$3

  echo "Config Decode $input --> $output using type $msgType"
  if [ ! -f $input ]; then
    echo "input file not found"
    exit 1
  fi

  configtxlator proto_decode \
    --type=${msgType} \
    --input=${input} \
    --output=${output}
}

# compute diff between two pb
# Usage: configtxlatorCompare channel origin updated output
configtxlatorCompare() {
  channel=$1
  origin=$2
  updated=$3
  output=$4

  echo "Config Compare $origin vs $updated > ${output} in channel $channel"
  if [ ! -f $origin ] || [ ! -f $updated ]; then
    echo "input file not found"
    exit 1
  fi

  configtxlator compute_update \
    --original=${origin} \
    --updated=${updated} \
    --channel_id=${channel} \
    --output=${output}

  [ $? -eq 0 ] || echo "Failed to compute config update"
}

# fetch the latest config block from channel and save as file
# Usage: fetchConfig channel msp_path ordererURL block_file_to_save
fetchConfig() {
  CHANNEL=$1
  MSP_PATH=$2
  orderer_url=$3
  BLOCK_FILE=$4

 peer channel fetch config ${BLOCK_FILE} \
    --connTimeout 10s \
    -c ${CHANNEL} \
    -o ${orderer_url} \
    --tls \
    --cafile ${MSP_PATH}/tlscacerts/tlsca.cert
}

# update a channel's config
# Usage: updateConfig channel msp_path ordererURL config_update_jq_kv
updateConfig() {
  CHANNEL=$1
  MSP_PATH=$2
  orderer_url=$3
  CFG_UPDATE_KV="$4"

  BLOCK_FILE=${CHANNEL}_config.block
  ORIGINAL_CFG_JSON=${CHANNEL}_origin_cfg.json
  ORIGINAL_CFG_PB=${CHANNEL}_origin_cfg.pb
  UPDATED_CFG_JSON=${CHANNEL}_updated_cfg.json
  UPDATED_CFG_PB=${CHANNEL}_updated_cfg.pb
  CFG_DELTA_JSON=${CHANNEL}_delta_cfg.json
  CFG_DELTA_PB=${CHANNEL}_delta_cfg.pb
  CFG_DELTA_ENV_JSON=${CHANNEL}_delta_env.json
  CFG_DELTA_ENV_PB=${CHANNEL}_delta_env.pb
  PAYLOAD_CFG_PATH=".data.data[0].payload.data.config"

  echo "===Fetching config block for channel ${CHANNEL}==="
  fetchConfig ${CHANNEL} ${MSP_PATH} ${orderer_url} ${BLOCK_FILE}

  echo "Decode config block for channel ${CHANNEL}"
  configtxlatorDecode "common.Block" ${BLOCK_FILE} ${BLOCK_FILE}.json

  jq "${PAYLOAD_CFG_PATH}" ${BLOCK_FILE}.json >${ORIGINAL_CFG_JSON}

  jq . ${ORIGINAL_CFG_JSON} >/dev/null
  [ $? -ne 0 ] && {
    echo "${ORIGINAL_CFG_JSON} is invalid"
    exit
  }

  # Check whether it has the key .channel_group.groups.Orderer.policies.Admins.policy.value.identities[0].principal.msp_identifier
  if jq -e '.channel_group.groups.Orderer.policies.Admins.policy.value.identities[0].principal | has("msp_identifier")' ${ORIGINAL_CFG_JSON} > /dev/null; then
    echo "The channel is updated, no need to take further action"
    return
  fi

  echo "Generate the pb with original config"
  configtxlatorEncode "common.Config" ${ORIGINAL_CFG_JSON} ${ORIGINAL_CFG_PB}

  echo "Generate the updated config"
  jq "${CFG_UPDATE_KV}" ${ORIGINAL_CFG_JSON} >${UPDATED_CFG_JSON}

  jq . ${UPDATED_CFG_JSON} > /dev/null
  [ $? -ne 0 ] && {
    echo "${UPDATED_CFG_JSON} is invalid" && exit 1
  }
  echo "Generate the updated pb with updated config"
  configtxlatorEncode "common.Config" ${UPDATED_CFG_JSON} ${UPDATED_CFG_PB}

  echo "Calculate the config delta between pb files"
  configtxlatorCompare ${CHANNEL} ${ORIGINAL_CFG_PB} ${UPDATED_CFG_PB} ${CFG_DELTA_PB}

  echo "Decode the config delta pb into json"
  configtxlatorDecode "common.ConfigUpdate" ${CFG_DELTA_PB} ${CFG_DELTA_JSON}
  jq . ${CFG_DELTA_JSON} >/dev/null
  [ $? -ne 0 ] && {
    echo "${CFG_DELTA_JSON} is invalid" && exit 1
  }
  echo "Wrap the config update as envelope"
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'"$CHANNEL"'", "type":2}},"data":{"config_update":'$(cat ${CFG_DELTA_JSON})'}}}' | jq . >${CFG_DELTA_ENV_JSON}

  echo "Encode the config update envelope into pb"
  configtxlatorEncode "common.Envelope" ${CFG_DELTA_ENV_JSON} ${CFG_DELTA_ENV_PB}

  echo "Sign the config update transaction"
  peer channel signconfigtx -f ${CFG_DELTA_ENV_PB}

  echo "Sending the config update tx to channel ${CHANNEL}"
  peer channel update \
    -c ${CHANNEL} \
    -o ${orderer_url} \
    -f ${CFG_DELTA_ENV_PB} \
    --tls \
    --cafile ${MSP_PATH}/tlscacerts/tlsca.cert

  echo "Rechecking the kv with channel ${CHANNEL}"
  fetchConfig ${CHANNEL} ${MSP_PATH} ${orderer_url} ${BLOCK_FILE}_new

  echo "Decode new config block for channel ${CHANNEL}"
  configtxlatorDecode "common.Block" ${BLOCK_FILE}_new ${BLOCK_FILE}_new.json

  jq "${PAYLOAD_CFG_PATH}" ${BLOCK_FILE}_new.json >${ORIGINAL_CFG_JSON}_new

  # Check whether it has the key .channel_group.groups.Orderer.policies.Admins.policy.value.identities[0].principal.msp_identifier
  if jq -e '.channel_group.groups.Orderer.policies.Admins.policy.value.identities[0].principal | has("msp_identifier")' ${ORIGINAL_CFG_JSON}_new > /dev/null; then
    echo "The channel is updated successfully"
    return
  fi
}


# Entrypoint
msp_id=$1
channel=$2
orderer_url=$3
founder=$4

msp_path=${PWD}/msp-${msp_id} # Suppose the msp path named as msp-${msp_id}

export FABRIC_LOGGING_SPEC="error"
export CORE_PEER_LOCALMSPID=${msp_id}
export CORE_PEER_MSPCONFIGPATH=${msp_path}
export CORE_PEER_TLS_ROOTCERT_FILE=${msp_path}/tlscacerts/tlsca.cert

#CFG_UPDATE_KEY=".data.data[0].payload.data.config.channel_group.groups.Orderer.values.ConsensusType.value.metadata.options.election_tick"
#CFG_UPDATE_KV=".channel_group.groups.Orderer.policies.Admins.policy=$(jsonDump "$founder")"
CFG_UPDATE_KV='.channel_group.groups.Orderer.policies.Admins.policy={"type":1,"value":{"identities":[{"principal":{"msp_identifier":"'"$founder"'","role":"ADMIN"},"principal_classification":"ROLE"}],"rule":{"n_out_of":{"n":1,"rules":[{"signed_by":0}]}},"version":0}}'
#CFG_UPDATE_KV='.channel_group.groups.Orderer.values.ConsensusType.value.metadata.options.heartbeat_tick=10"
#CFG_UPDATE_KEY=".data.data[0].payload.data.config.channel_group.groups.Orderer.values.ConsensusType.value.metadata.options.heartbeat_tick"
#CFG_UPDATE_VALUE=10

updateConfig $channel ${msp_path} ${orderer_url} ${CFG_UPDATE_KV}

exit 0