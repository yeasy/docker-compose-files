#!/bin/bash
# Commit a chaincode definition
# Usage: ./script mspId peerAddr channelId ccName ccVersion endorPolicy ordererAddr mspPath=${PWD}/msp-mspId

# Entry function
main() {
  if [ $# -lt 7 ]; then
    echo "Not enough argument supplied"
    echo "$(basename $0) mspId peerAddr channelId ccName ccVersion endorPolicy ordererAddr mspPath=${PWD}/msp-mspId"
    exit 1
  fi

  local mspId=$1
  local channelId=$2
  local peerAddr=$3
  local ordererAddr=$4
  local ccName=$5
  local ccVersion=$6
  local endorPolicy=$7
  local mspPath=${8:-${PWD}/msp-${mspId}} # Suppose the local msp named as msp-${msp_id}

  export FABRIC_LOGGING_SPEC="debug"
  export CORE_PEER_ADDRESS="${peerAddr}"
  export CORE_PEER_LOCALMSPID=${mspId}
  export CORE_PEER_MSPCONFIGPATH=${mspPath}
  export CORE_PEER_TLS_ROOTCERT_FILE=${mspPath}/tlscacerts/tlsca.cert
  export CORE_PEER_TLS_ENABLED=true

  echo "commit chaincode definition peerAddr=${peerAddr}, channelId=${channelId}, ccVersion=${ccVersion}, endorPolicy=${endorPolicy}, ordererAddr=${ordererAddr}"
  peer lifecycle chaincode commit \
    --peerAddresses "${peerAddr}" \
    --tlsRootCertFiles "${CORE_PEER_TLS_ROOTCERT_FILE}" \
    --channelID ${channelId} \
    --name ${ccName} \
    --version ${ccVersion} \
    --init-required \
    --sequence 1 \
    --signature-policy "${endorPolicy}" \
    --waitForEvent \
    --orderer ${ordererAddr} \
    --tls true \
    --cafile ${CORE_PEER_TLS_ROOTCERT_FILE}

  peer lifecycle chaincode querycommitted \
    --peerAddresses ${peerAddr} \
    --tlsRootCertFiles ${CORE_PEER_TLS_ROOTCERT_FILE} \
    --channelID ${channelId} \
    --output json \
    --name ${ccName}

  exit 0
}

main "$@"