#!/bin/bash
# Invoke a chaincode
# Usage: ./script mspId channel ordererAddr peerAddr ccName mspPath=${PWD}/msp-mspId

# Entry function
main() {
  if [ $# -lt 5 ]; then
    echo "Not enough argument supplied"
    echo "$(basename $0) mspId channel ordererAddr peerAddr ccName mspPath=${PWD}/msp-mspId"
    exit 1
  fi

  local mspId=$1
  local channel=$2
  local ordererAddr=$3
  local peerAddr=$4
  local ccName=$5
  local mspPath=${6:-${PWD}/msp-${mspId}} # Suppose the local msp path named as msp-${msp_id}

  export FABRIC_LOGGING_SPEC="debug"
  export CORE_PEER_ADDRESS="${peerAddr}"
  export CORE_PEER_LOCALMSPID=${mspId}
  export CORE_PEER_MSPCONFIGPATH=${mspPath}
  export CORE_PEER_TLS_ROOTCERT_FILE=${mspPath}/tlscacerts/tlsca.cert
  export CORE_PEER_TLS_ENABLED=true

  peer chaincode invoke \
    --connTimeout="30s" \
    -o "${ordererAddr}" \
    -C "${channel}" \
    -n "${ccName}" \
    --peerAddresses "${peerAddr}" \
    --tlsRootCertFiles "${CORE_PEER_TLS_ROOTCERT_FILE}" \
    -c '{"Args":["invoke","a","b","10"]}' \
    --tls \
    --cafile "${CORE_PEER_TLS_ROOTCERT_FILE}"

    exit 0

    peer chaincode query \
    --connTimeout=30s \
    -C "${channel}" \
    -n "${ccName}" \
    --peerAddresses "${peerAddr}" \
    --tlsRootCertFiles "${CORE_PEER_TLS_ROOTCERT_FILE}" \
    -c '{"Args":["query","b"]}'
}

main "$@"
