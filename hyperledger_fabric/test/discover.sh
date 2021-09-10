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

  export FABRIC_LOGGING_SPEC="info"
  export CORE_PEER_ADDRESS="${peerAddr}"
  export CORE_PEER_LOCALMSPID=${mspId}
  export CORE_PEER_MSPCONFIGPATH=${mspPath}
  export CORE_PEER_TLS_ROOTCERT_FILE=${mspPath}/tlscacerts/tlsca.cert
  export CORE_PEER_TLS_ENABLED=true

  #for i in {1..1000}; do
  #  echo -n "round $i: "
  discover \
    --peerTLSCA "${CORE_PEER_TLS_ROOTCERT_FILE}" \
    --userKey ${mspPath}/keystore/${mspId}-key \
    --userCert ${mspPath}/signcerts/${mspId}-cert.pem \
    --MSP "${mspId}" \
    peers \
    --channel "${channel}" \
    --server "${peerAddr}" >peers.json

  #if [ $(jq length peers.json) == 4 ]; then
  #  echo "detected 4 peers"
  #else
  #  cat peers.json
  #  cp peers.json peers-${i}.json
  #  echo $(date) >>peers-${i}.json
  #fi
  sleep 1
  #done

  discover \
    --peerTLSCA "${CORE_PEER_TLS_ROOTCERT_FILE}" \
    --userKey ${mspPath}/keystore/${mspId}-key \
    --userCert ${mspPath}/signcerts/${mspId}-cert.pem \
    --MSP "${mspId}" \
    endorsers \
    --channel "${channel}" \
    --chaincode "${ccName}" \
    --server "${peerAddr}" >endorsers.json

  #if [ $(jq '.[0].EndorsersByGroups|length' endorsers.json) == 2 ]; then
  #  echo "2"
  #else
  #  cat endorsers.json
  #  cp endorsers.json endorsers-1.json
  #fi
  #sleep 1

  #--tlsCert tls/client.crt \
  #--tlsKey tls/client.key \
}

main "$@"
