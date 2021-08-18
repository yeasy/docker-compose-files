#!/bin/bash
# Package a chaincode
# Usage: ./script mspId ccName ccPath ccLabel ccLang=golang mspPath=${PWD}/msp-mspId

# Entry function
main() {
  if [ $# -lt 4 ]; then
    echo "Not enough argument supplied"
    echo "$(basename $0) mspId ccName ccPath ccLabel ccLang=golang mspPath=${PWD}/msp-mspId"
    exit 1
  fi

  local mspId=$1
  local ccName=$2
  local ccPath=$3
  local ccLabel=$4
  local ccLang=${5:-golang}
  local mspPath=${6:-${PWD}/msp-${mspId}} # Suppose the local msp path named as msp-${msp_id}

  export FABRIC_LOGGING_SPEC="debug"
  export CORE_PEER_LOCALMSPID=${mspId}
  export CORE_PEER_MSPCONFIGPATH=${mspPath}
  export CORE_PEER_TLS_ROOTCERT_FILE=${mspPath}/tlscacerts/tlsca.cert
  export CORE_PEER_TLS_ENABLED=true

  echo "packaging chaincode=${ccName} with path=${ccPath}, label=${ccLabel}, lang=${ccLang}"
  peer lifecycle chaincode package ${ccName}.tar.gz \
    --path ${ccPath} \
    --label ${ccLabel} \
    --lang ${ccLang}

  exit 0
}

main "$@"