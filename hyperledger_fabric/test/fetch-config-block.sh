#!/bin/bash
# Fetch a config block and decode it. It will generate 3 local files:
# ${channel}_config.block: the config block;
# ${channel}_config.block.json: decoded config block;
# ${channel}_config.block.cfg.json: core config section of the config blcok

# Usage: ./script channel ordererURL mspId mspPath=${PWD}/msp-mspId

# use configtxlator to decode pb to json
# Usage: configtxlatorEncode msgType input output
configtxlatorDecode() {
  local msgType=$1
  local input=$2
  local output=$3

  if [ ! -f "$input" ]; then
    echo "configDecode: input file not found"
    exit 1
  fi

  if ! command -v configtxlator &> /dev/null; then
    echo "configtxlator could not be found, please install it first"
    exit 1
  fi

  echo "Config Decode $input --> $output using type $msgType"
  configtxlator proto_decode \
    --type="${msgType}" \
    --input="${input}" \
    --output="${output}"
}

# fetchConfigBlock fetch the config block
# Usage: fetchConfigBlock channel ordererURL tlscaFile
fetchConfigBlock() {
  local channel=$1
  local ordererURL=$2
  local tlscaFile=$3
  local config_block=${channel}_config.block
  PAYLOAD_CFG_PATH=".data.data[0].payload.data.config"

  peer channel fetch config "${config_block}" \
    -c "${channel}" \
    -o "${ordererURL}" \
    --tls \
    --cafile "${tlscaFile}"

  echo "[${channel}] Decode config block into ${channel}_config.block.json"
  configtxlatorDecode "common.Block" "${channel}_config.block" "${channel}_config.block.json"

  echo "[${channel}] Export the config section ${PAYLOAD_CFG_PATH} from config block into ${channel}_config.block.cfg.json"
  jq "${PAYLOAD_CFG_PATH}" "${channel}_config.block.json" >"${channel}_config.block.cfg.json"
}

if [ $# -eq 0 ]; then
  echo "Please use the <mspId> <channel> <ordererURL> as the argument"
  exit
fi

# Entry function
main() {
  if [ $# -lt 3 ]; then
    echo "Not enough argument supplied"
    echo "$(basename $0) channel ordererURL mspId mspPath=${PWD}/msp-mspId"
    exit 1
  fi
  local channel=$1
  local ordererURL=$2
  local mspId=$3
  local mspPath=${4:-${PWD}/msp-${mspId}} # Suppose the local msp path named as msp-${msp_id}

  export FABRIC_LOGGING_SPEC="debug"
  export CORE_PEER_LOCALMSPID=${mspId}
  export CORE_PEER_MSPCONFIGPATH=${mspPath}
  export CORE_PEER_TLS_ROOTCERT_FILE=${mspPath}/tlscacerts/tlsca.cert
  #export CORE_PEER_TLS_ENABLED=true # Let client use TLS connection when connecting to peer

  echo "[${channel}] Fetch config block and decode it into JSON"
  fetchConfigBlock "${channel}" "${ordererURL}" "${CORE_PEER_TLS_ROOTCERT_FILE}"
}

main "$@"
