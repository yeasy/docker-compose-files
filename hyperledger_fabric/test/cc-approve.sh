#!/bin/bash
# Approve a chaincode definition
# Usage: ./script mspId channelID peerAddr ordererAddr ccName ccVersion packageId endorPolicy mspPath=${PWD}/msp-mspId

# Entry function
main() {
  if [ $# -lt 8 ]; then
    echo "Not enough argument supplied"
    echo "$(basename $0) mspId channelID peerAddr ordererAddr ccName ccVersion packageId endorPolicy mspPath=${PWD}/msp-mspId"
    exit 1
  fi

  local mspId=$1
  local channelID=$2
  local peerAddr=$3
  local ordererAddr=$4
  local ccName=$5
  local ccVersion=$6
  local packageId=$7
  local endorPolicy=$8
  local mspPath=${9:-${PWD}/msp-${mspId}} # Suppose the local msp named as msp-${msp_id}

  export FABRIC_LOGGING_SPEC="debug"
  export CORE_PEER_ADDRESS="${peerAddr}"
  export CORE_PEER_LOCALMSPID=${mspId}
  export CORE_PEER_MSPCONFIGPATH=${mspPath}
  export CORE_PEER_TLS_ROOTCERT_FILE=${mspPath}/tlscacerts/tlsca.cert
  export CORE_PEER_TLS_ENABLED=true

  echo "approve chaincode definition peerAddr=${peerAddr}, channelID=${channelID}, ccVersion=${ccVersion}, packageId=${packageId}, endorPolicy=${endorPolicy}, ordererAddr=${ordererAddr}"
  peer lifecycle chaincode approveformyorg \
	--peerAddresses "${peerAddr}" \
	--tlsRootCertFiles "${CORE_PEER_TLS_ROOTCERT_FILE}" \
	--channelID ${channelID} \
  --name ${ccName} \
  --version ${ccVersion} \
  --init-required \
  --package-id ${packageId} \
  --sequence 1 \
  --signature-policy "${endorPolicy}" \
  --waitForEvent \
  --orderer ${ordererAddr} \
  --tls true \
  --cafile ${CORE_PEER_TLS_ROOTCERT_FILE}

  exit 0
}

main "$@"