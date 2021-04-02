#!/bin/bash
# Invoke a chaincode
# Usage: ./script mspId peerAddr mspPath=${PWD}/msp-mspId

# Entry function
main() {
  if [ $# -lt 2 ]; then
    echo "Not enough argument supplied"
    echo "$(basename $0) mspId peerAddr mspPath=${PWD}/msp-mspId"
    exit 1
  fi

  local mspId=$1
  local peerAddr=$2
  local mspPath=${3:-${PWD}/msp-${mspId}} # Suppose the local msp path named as msp-${msp_id}

  export FABRIC_LOGGING_SPEC="debug"
  export CORE_PEER_ADDRESS="${peerAddr}"
  export CORE_PEER_LOCALMSPID=${mspId}
  export CORE_PEER_MSPCONFIGPATH=${mspPath}
  export CORE_PEER_TLS_ROOTCERT_FILE=${mspPath}/tlscacerts/tlsca.cert
  export CORE_PEER_TLS_ENABLED=true

  #export GRPC_GO_REQUIRE_HANDSHAKE=off

  peer chaincode list \
    --connTimeout=30s \
    --installed \
    --peerAddresses "${peerAddr}" \
    --tlsRootCertFiles "${CORE_PEER_TLS_ROOTCERT_FILE}"

  exit 0
}

main "$@"
