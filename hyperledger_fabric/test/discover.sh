#!/bin/bash
# Invoke a chaincode
# Usage: ./script mspId channel peerAddr ccName mspPath=${PWD}/msp-mspId

# Entry function
main() {
  if [ $# -lt 4 ]; then
    echo "Not enough argument supplied"
    echo "$(basename $0) mspId channel peerAddr ccName mspPath=${PWD}/msp-mspId"
    exit 1
  fi

  local mspId=$1
  local channel=$2
  local peerAddr=$3
  local ccName=$4
  local mspPath=${5:-${PWD}/msp-${mspId}} # Suppose the local msp path named as msp-${msp_id}

  export FABRIC_LOGGING_SPEC="debug"
  export CORE_PEER_ADDRESS="${peerAddr}"
  export CORE_PEER_LOCALMSPID=${mspId}
  export CORE_PEER_MSPCONFIGPATH=${mspPath}
  export CORE_PEER_TLS_ROOTCERT_FILE=${mspPath}/tlscacerts/tlsca.cert
  export CORE_PEER_TLS_ENABLED=true

  discover \
    --peerTLSCA "${CORE_PEER_TLS_ROOTCERT_FILE}" \
    --userKey ${mspPath}/keystore/${mspId}-key \
    --userCert ${mspPath}/signcerts/${mspId}-cert.pem \
    --MSP "${mspId}" \
    endorsers \
    --channel "${channel}" \
    --chaincode "${ccName}" \
    --server "${peerAddr}"
    #--tlsCert tls/client.crt \
    #--tlsKey tls/client.key \
}

main "$@"
