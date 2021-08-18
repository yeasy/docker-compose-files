#!/bin/bash
# Install a chaincode from package
# Usage: ./script mspId peerAddr ccPkg mspPath=${PWD}/msp-mspId

# Entry function
main() {
  if [ $# -lt 3 ]; then
    echo "Not enough argument supplied"
    echo "$(basename $0) mspId peerAddr ccPkg mspPath=${PWD}/msp-mspId"
    exit 1
  fi

  local mspId=$1
  local peerAddr=$2
  local ccPkg=$3
  local mspPath=${4:-${PWD}/msp-${mspId}} # Suppose the local msp named as msp-${msp_id}

  export FABRIC_LOGGING_SPEC="debug"
  export CORE_PEER_ADDRESS="${peerAddr}"
  export CORE_PEER_LOCALMSPID=${mspId}
  export CORE_PEER_MSPCONFIGPATH=${mspPath}
  export CORE_PEER_TLS_ROOTCERT_FILE=${mspPath}/tlscacerts/tlsca.cert
  export CORE_PEER_TLS_ENABLED=true

  echo "installing chaincode to peer=${peerAddr}"
  peer lifecycle chaincode install \
    --peerAddresses "${peerAddr}" \
    --tlsRootCertFiles "${CORE_PEER_TLS_ROOTCERT_FILE}" \
    ${ccPkg}

  exit 0

  peer lifecycle chaincode queryinstalled \
    --peerAddresses "${peerAddr}" \
    --tlsRootCertFiles "${CORE_PEER_TLS_ROOTCERT_FILE}" \
    --output json

  exit 0
}

main "$@"