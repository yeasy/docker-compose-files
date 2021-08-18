#!/bin/bash
# Install a chaincode
# Usage: ./script mspId peerAddr mspPath=${PWD}/msp-mspId name version path

# Entry function
main() {
  if [ $# -lt 5 ]; then
    echo "Not enough argument supplied"
    echo "$(basename $0) mspId peerAddr mspPath=${PWD}/msp-mspId name version path"
    exit 1
  fi

  local mspId=$1
  local peerAddr=$2
  local mspPath=${3:-${PWD}/msp-${mspId}} # Suppose the local msp path named as msp-${msp_id}
  local name=$4
  local version=$5
  local path=$6
  local lang="golang"

  export FABRIC_LOGGING_SPEC="debug"
  export CORE_PEER_ADDRESS="${peerAddr}"
  export CORE_PEER_LOCALMSPID=${mspId}
  export CORE_PEER_MSPCONFIGPATH=${mspPath}
  export CORE_PEER_TLS_ROOTCERT_FILE=${mspPath}/tlscacerts/tlsca.cert
  export CORE_PEER_TLS_ENABLED=true

  #export GRPC_GO_REQUIRE_HANDSHAKE=off

  peer chaincode install \
		-n ${name} \
		-v $version \
		-p ${path} \
		-l ${lang} \
		--peerAddresses "${peerAddr}" \
		--tlsRootCertFiles "${CORE_PEER_TLS_ROOTCERT_FILE}"

  exit 0
}

main "$@"