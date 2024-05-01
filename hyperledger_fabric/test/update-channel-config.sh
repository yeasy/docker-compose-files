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
  local msgType=$1
  local input=$2
  local output=$3

  echo "Encode $input --> $output using type $msgType"
  configtxlator proto_encode \
    --type=${msgType} \
    --input=${input} \
    --output=${output}
    
  [ $? -eq 0 ] || { echo "Failed to do pb encode"; exit 1; }
}

# configtxlator decode pb to json
# Usage: configtxlatorEncode msgType input output
configtxlatorDecode() {
  local msgType=$1
  local input=$2
  local output=$3

  echo "Config Decode $input --> $output using type $msgType"
  if [ ! -f $input ]; then
    echo "input file not found"
    exit 1
  fi

  configtxlator proto_decode \
    --type=${msgType} \
    --input=${input} \
    --output=${output}

  [ $? -eq 0 ] || { echo "Failed to do pb decode"; exit 1; }
}

# compute diff between two pb
# Usage: configtxlatorCompare channel origin updated output
configtxlatorCompare() {
  local channel=$1
  local origin=$2
  local updated=$3
  local output=$4

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

  [ $? -eq 0 ] || { echo "Failed to compute config update"; exit 1; }
}

# fetch the latest config block from channel and save as file
# Usage: fetchConfig channel msp_path ordererURL block_file_to_save
fetchConfig() {
  local channel=$1
  local msp_path=$2
  local orderer_url=$3
  local block_file=$4

 peer channel fetch config ${block_file} \
    --connTimeout 10s \
    -c ${channel} \
    -o ${orderer_url} \
    --tls \
    --cafile ${msp_path}/tlscacerts/tlsca.cert
}

# update a channel's config
# Usage: updateConfig channel msp_path ordererURL config_update_jq_kv
updateConfig() {
  local channel=$1
  local msp_path=$2
  local orderer_url=$3
  local cfg_update_kv="$4"

  local block_file=${channel}_config.block
  local original_cfg_json=${channel}_origin_cfg.json
  local original_cfg_pb=${channel}_origin_cfg.pb
  local updated_cfg_json=${channel}_updated_cfg.json
  local updated_cfg_pb=${channel}_updated_cfg.pb
  local cfg_delta_json=${channel}_delta_cfg.json
  local cfg_delta_pb=${channel}_delta_cfg.pb
  local cfg_delta_env_json=${channel}_delta_env.json
  local cfg_delta_env_pb=${channel}_delta_env.pb
  local payload_cfg_path=".data.data[0].payload.data.config"
  
  echo "===Fetching config block for channel ${channel}==="
  fetchConfig ${channel} ${msp_path} ${orderer_url} ${block_file}

  echo "Decode config block to json for channel ${channel}"
  configtxlatorDecode "common.Block" ${block_file} ${block_file}.json

  echo "Parse the payload part of the channel config json"
  jq "${payload_cfg_path}" ${block_file}.json >${original_cfg_json}
  jq . ${original_cfg_json} >/dev/null
  [ $? -ne 0 ] && { echo "${original_cfg_json} is invalid"; exit 1; }

  # Check whether it has the key .channel_group.groups.Orderer.policies.Admins.policy.value.identities[0].principal.msp_identifier
  if jq -e '.channel_group.groups.Orderer.policies.Admins.policy.value.identities[0].principal | has("msp_identifier")' ${ORIGINAL_CFG_JSON} > /dev/null; then
    echo "The channel is updated, no need to take further action"
    return
  fi

  echo "Generate the pb with original config"
  configtxlatorEncode "common.Config" ${original_cfg_json} ${original_cfg_pb}

  echo "Generate the updated config as ${updated_cfg_json}"
  jq "${cfg_update_kv}" ${original_cfg_json} >${updated_cfg_json}

  jq . ${updated_cfg_json} > /dev/null
  [ $? -ne 0 ] && {
    echo "${updated_cfg_json} is invalid" && exit 1
  }
  
  echo "Generate the updated pb with updated config"
  configtxlatorEncode "common.Config" ${updated_cfg_json} ${updated_cfg_pb}

  echo "Calculate the config delta between pb files"
  configtxlatorCompare ${channel} ${original_cfg_pb} ${updated_cfg_pb} ${cfg_delta_pb}
  
  [ $? -ne 0 ] && { echo "Error to calculate the delta pb file, no difference?"; exit 1; }

  echo "Decode the config delta pb into json as ${cfg_delta_json}"
  configtxlatorDecode "common.ConfigUpdate" ${cfg_delta_pb} ${cfg_delta_json}
  jq . ${cfg_delta_json} >/dev/null
  [ $? -ne 0 ] && {
    echo "${cfg_delta_json} is invalid" && exit 1
  }
  echo "Wrap the config update in envelope as ${cfg_delta_env_json}"
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'"$channel"'", "type":2}},"data":{"config_update":'$(cat ${cfg_delta_json})'}}}' | jq . >${cfg_delta_env_json}

  echo "Encode the config update envelope into pb as ${cfg_delta_env_pb}"
  configtxlatorEncode "common.Envelope" ${cfg_delta_env_json} ${cfg_delta_env_pb}

  echo "Sign the config update transaction"
  peer channel signconfigtx -f ${cfg_delta_env_pb}

  echo "Sending the config update tx to channel ${channel}"
  peer channel update \
    -c ${channel} \
    -o ${orderer_url} \
    -f ${cfg_delta_env_pb} \
    --tls \
    --cafile ${msp_path}/tlscacerts/tlsca.cert

  echo "Rechecking the kv with channel ${channel}"
  fetchConfig ${channel} ${msp_path} ${orderer_url} ${block_file}_new

  echo "Decode the payload of new config block of ${block_file}_new for channel ${channel} as ${block_file}_new_payload.json"
  configtxlatorDecode "common.Block" ${block_file}_new ${block_file}_new.json
  jq "${payload_cfg_path}" ${block_file}_new.json >${block_file}_new_payload.json

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