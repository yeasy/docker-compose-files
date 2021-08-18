#!/bin/bash
# Get the chaincode data
# Usage: ./script mspId channelID peerAddr ccName

setupChaincode() {
  local channelID=$1
  local peerAddr=$2
  local tlsca_file=$3

  peer chaincode instantiate \
    -o "dhnodeouf5-bcsnativepreprod-iad.blockchain.ocp.oc-test.com:20003" \
    -C ${channelID} \
    -n "exp02" \
    -v "v1" \
    -c '{"Args":["init","a","100","b","200"]}' \
    -P "OR ('dhnodeOUf5.peer','dhnodeOUf6.peer')" \
    --tls \
    --cafile ${tlsca_file} \
    --peerAddr ${peerAddr} \
    --tlsRootCertFiles ${tlsca_file}
}

# getChaincodeData get the instantiated chaincode information
# Usage: getChaincodeData channelID peerAddr ccName
getChaincodeData() {
  local channelID=$1
  local peerAddr=$2
  local ccName=$3
  local tlsca_file=$4

  peer chaincode query \
    --connTimeout 10s \
    --channelID ${channelID} \
    -n "lscc" \
    -c '{"Args":["getccdata","'${channelID}'","'${ccName}'"]}' \
    --tls \
    --peerAddresses ${peerAddr} \
    --tlsRootCertFiles ${tlsca_file} \
    > chaincode.ccdata

  peer chaincode query \
    --connTimeout 10s \
    --channelID ${channelID} \
    -n "lscc" \
    -c '{"Args":["getdepspec","'${channelID}'","'${ccName}'"]}' \
    --tls \
    --peerAddresses ${peerAddr} \
    --tlsRootCertFiles ${tlsca_file} \
    > chaincode.depspec
}

if [ $# -eq 0 ]; then
  echo "Please use the <mspId> <channelID> <ordererURL> as the argument"
  exit
fi

mspId=$1
channelID=$2
peerAddr=$3
ccName=$4

echo "mspId=${mspId}"
echo "channelID=${channelID}"
echo "peerAddr=${peerAddr}"
echo "ccName=${ccName}"

msp_path=${PWD}/msp-${mspId} # Suppose the local msp path named as msp-${mspId}

export FABRIC_LOGGING_SPEC="debug"
export CORE_PEER_LOCALMSPID=${mspId}
#export CORE_PEER_ADDRESS=${peerAddr}
export CORE_PEER_MSPCONFIGPATH=${msp_path}
export CORE_PEER_TLS_ROOTCERT_FILE=${msp_path}/tlscacerts/tlsca.cert
export CORE_PEER_TLS_ENABLED=true

#setupChaincode ${channelID} ${peerAddr} ${msp_path}/tlscacerts/tlsca.cert
getChaincodeData ${channelID} ${peerAddr} ${ccName} ${msp_path}/tlscacerts/tlsca.cert
