#!/bin/bash
# Fetch a config block and decode it

setupChaincode() {
  local channel=$1
  local peerAddresses=$2
  local tlsca_file=$3

  peer chaincode instantiate \
    -o "dhnodeouf5-bcsnativepreprod-iad.blockchain.ocp.oc-test.com:20003" \
    -C ${channel} \
    -n "exp02" \
    -v "v1" \
    -c '{"Args":["init","a","100","b","200"]}' \
    -P "OR ('dhnodeOUf5.peer','dhnodeOUf6.peer')" \
    --tls \
    --cafile ${tlsca_file} \
    --peerAddresses ${peerAddresses} \
    --tlsRootCertFiles ${tlsca_file}
}

# getInstantiatedChaincode get the instantiated chaincode information
# Usage: getInstantiatedChaincode channel peer-addresses
getInstantiatedChaincode() {
  local channel=$1
  local peerAddresses=$2
  local tlsca_file=$3

  peer chaincode query \
    --connTimeout 10s \
    --channelID ${channel} \
    -n "lscc" \
    -c '{"Args":["getccdata","default","c040953"]}' \
    --tls \
    --peerAddresses ${peerAddresses} \
    --tlsRootCertFiles ${tlsca_file}
}

if [ $# -eq 0 ]; then
  echo "Please use the <mspId> <channel> <ordererURL> as the argument"
  exit
fi

msp_id=$1
channel=$2
peerAddresses=$3

echo "msp_id=${msp_id}"
echo "channel=${channel}"
echo "peerAddresses=${peerAddresses}"

msp_path=${PWD}/msp-${msp_id} # Suppose the local msp path named as msp-${msp_id}

export FABRIC_LOGGING_SPEC="debug"
export CORE_PEER_LOCALMSPID=${msp_id}
#export CORE_PEER_ADDRESS=${peerAddresses}
export CORE_PEER_MSPCONFIGPATH=${msp_path}
export CORE_PEER_TLS_ROOTCERT_FILE=${msp_path}/tlscacerts/tlsca.cert
export CORE_PEER_TLS_ENABLED=true

setupChaincode ${channel} ${peerAddresses} ${msp_path}/tlscacerts/tlsca.cert
#getInstantiatedChaincode ${channel} ${peerAddresses} ${msp_path}/tlscacerts/tlsca.cert
