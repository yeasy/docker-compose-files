#!/usr/bin/env bash

echo_r() {
  [ $# -ne 1 ] && return 0
  echo -e "\033[31m$1\033[0m"
}
echo_g() {
  [ $# -ne 1 ] && return 0
  echo -e "\033[32m$1\033[0m"
}
echo_y() {
  [ $# -ne 1 ] && return 0
  echo -e "\033[33m$1\033[0m"
}
echo_b() {
  [ $# -ne 1 ] && return 0
  echo -e "\033[34m$1\033[0m"
}

# Define those global variables
if [ -f ./variables.sh ]; then
  source ./variables.sh
elif [ -f scripts/variables.sh ]; then
  source scripts/variables.sh
else
  echo_r "Cannot find the variables.sh files, pls check"
  exit 1
fi

RUN_LOG_FILE="/tmp/hlf-func-${BASHPID:-$$}.log"
QUERY_LOG_FILE="/tmp/hlf-func-${BASHPID:-$$}-query.log"

# Verify $1 is not 0, then output error msg $2 and exit
verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "$2"
    echo_r "=== ERROR !!! FAILED to execute End-2-End Scenario ==="
    exit 1
  fi
}

# set env to use orderOrg's identity
setOrdererEnvs() {
  export CORE_PEER_LOCALMSPID="OrdererMSP"
  export CORE_PEER_MSPCONFIGPATH=${ORDERER0_ADMIN_MSP}
  export CORE_PEER_TLS_ROOTCERT_FILE=${ORDERER0_TLS_ROOTCERT}
  #t="\${ORG${org}_PEER${peer}_URL}" && CORE_PEER_ADDRESS=`eval echo $t`
}

# Set global env variables for fabric cli, after setting:
# client is the admin as given org
# TLS root cert is configured to given peer's tls ca
# remote peer address is configured to given peer's

# CORE_PEER_LOCALMSPID=Org1MSP  # local msp id to use
# CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp  # local msp path to use
# CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt  # local trusted tls ca cert
# CORE_PEER_ADDRESS=peer0.org1.example.com:7051  # remote peer to send proposal to

# Usage: setEnvs org peer
setEnvs() {
  local org=$1  # 1 or 2
  local peer=$2 # 0 or 1
  [ -z $org ] && [ -z $peer ] && echo_r "input param invalid" && exit -1

  local t=""
  export CORE_PEER_LOCALMSPID="Org${org}MSP"
  #CORE_PEER_MSPCONFIGPATH=\$${ORG${org}_ADMIN_MSP}
  t="\${ORG${org}_PEER${peer}_URL}" && export CORE_PEER_ADDRESS=$(eval echo $t) # this is not needed if specifying peerAddresses
  t="\${ORG${org}_ADMIN_MSP}" && export CORE_PEER_MSPCONFIGPATH=$(eval echo $t)
  t="\${ORG${org}_PEER${peer}_TLS_ROOTCERT}" && export CORE_PEER_TLS_ROOTCERT_FILE=$(eval echo $t)

  #env |grep CORE
  export FABRIC_LOGGING_SPEC="INFO"
  #export GOCACHE=/root/.cache/go-build
  #go get
}

getOrgTestPeer() {
  local org=$1
  local t="\${ORG${org}_TEST_PEER}"
  eval echo "$t"
}

getOrgPeerUrl() {
  local org=$1
  local peer=$2
  local t="\${ORG${org}_PEER${peer}_URL}"
  eval echo "$t"
}

getOrgPeerTlsRootcert() {
  local org=$1
  local peer=$2
  local t="\${ORG${org}_PEER${peer}_TLS_ROOTCERT}"
  eval echo "$t"
}

# Internal func called by channelCreate
# channelCreateAction channel tx orderer_url orderer_tls_rootcert
channelCreateAction() {
  local channel=$1
  local channel_tx=$2
  local orderer_url=$3
  local orderer_tls_rootcert=$4

  if [ -z "$CORE_PEER_TLS_ENABLED" ] || [ "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    peer channel create \
      -c ${channel} \
      -o ${orderer_url} \
      -f ${CHANNEL_ARTIFACTS}/${channel_tx} \
      --timeout "${TIMEOUT}s"
  else
    peer channel create \
      -c ${channel} \
      -o ${orderer_url} \
      -f ${CHANNEL_ARTIFACTS}/${channel_tx} \
      --timeout "${TIMEOUT}s" \
      --tls \
      --cafile ${orderer_tls_rootcert}
  fi
  return $?
}

# Use peer0/org1's identity to create a channel
# channelCreate APP_CHANNEL APP_CHANNEL.tx org peer orderer_url orderer_tls_rootcert
channelCreate() {
  local channel=$1
  local tx=$2
  local org=$3
  local peer=$4
  local orderer_url=$5
  local orderer_tls_rootcert=$6

  [ -z $channel ] && [ -z $tx ] && [ -z $org ] && [ -z $peer ] && echo_r "input param invalid" && exit -1

  echo "=== Create Channel ${channel} by org $org/peer $peer === "
  setEnvs $org $peer
  local rc=1
  local counter=0
  while [ ${counter} -lt ${MAX_RETRY} -a ${rc} -ne 0 ]; do
    channelCreateAction ${channel} ${tx} ${orderer_url} ${orderer_tls_rootcert}
    rc=$?
    let counter=${counter}+1
    #COUNTER=` expr $COUNTER + 1`
    [ $rc -ne 0 ] && echo "Failed to create channel $channel, retry after 5s" && sleep 5
  done
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult ${rc} "Channel ${channel} creation failed"
  echo "=== Channel ${channel} is created. === "
}

# called by channelJoinWithRetry
channelJoinAction() {
  local channel=$1
  local block_file="${CHANNEL_ARTIFACTS}/${channel}.block"
  [ -f "${CHANNEL_ARTIFACTS}/${channel}_0.block" ] && block_file="${CHANNEL_ARTIFACTS}/${channel}_0.block"
  peer channel join \
    -b ${block_file} \
    >"$RUN_LOG_FILE" 2>&1
}

## Sometimes Join takes time hence RETRY atleast for 5 times
channelJoinWithRetry() {
  local channel=$1
  local peer=$2
  local counter=0
  channelJoinAction ${channel}
  local rc=$?
  while [ ${counter} -lt ${MAX_RETRY} -a ${rc} -ne 0 ]; do
    echo "peer${peer} failed to join channel ${channel}, retry after 2s"
    sleep 2
    channelJoinAction ${channel}
    rc=$?
    let counter=${counter}+1
  done
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult ${rc} "After $MAX_RETRY attempts, peer${peer} failed to Join the Channel"
}

# Join given (by default all) peers into the channel
# channelJoin channel org peer
channelJoin() {
  local channel=$1
  local org=$2
  local peer=$3
  [ -z $channel ] && [ -z $org ] && [ -z $peer ] && echo_r "input param invalid" && exit -1

  echo "=== Join org $org/peer $peer into channel ${channel} === "
  setEnvs $org $peer
  channelJoinWithRetry ${channel} $peer
  echo "=== org $org/peer $peer joined into channel ${channel} === "
}

getShaSum() {
  [ ! $# -eq 1 ] && exit 1
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum ${1} | awk '{print $1}'
  else
    shasum ${1} | awk '{print $1}'
  fi
}

# List the channel that the peer joined
# E.g., for peer 0 at org 1, will do
# channelList 1 0
channelList() {
  local org=$1
  local peer=$2
  echo "=== List the channels that org${org}/peer${peer} joined === "

  setEnvs $org $peer

  peer channel list >"$RUN_LOG_FILE" 2>&1
  rc=$?
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  if [ $rc -ne 0 ]; then
    echo "=== Failed to list the channels that org${org}/peer${peer} joined === "
  else
    echo "=== Done to list the channels that org${org}/peer${peer} joined === "
  fi
}

# Get the info of specific channel, including {height, currentBlockHash, previousBlockHash}.
# E.g., for peer 0 at org 1, get info of business channel will do
# channelGetInfo businesschannel 1 0
channelGetInfo() {
  local channel=$1
  local org=$2
  local peer=$3
  echo "=== Get channel info (height, currentBlockHash, previousBlockHash) of ${channel} with id of org${org}/peer${peer} === "

  setEnvs $org $peer

  peer channel getinfo -c ${channel} >"$RUN_LOG_FILE" 2>&1
  rc=$?
  cat "$RUN_LOG_FILE"
  if [ $rc -ne 0 ]; then
    echo "=== Fail to get channel info of ${channel} with id of org${org}/peer${peer} === "
  else
    echo "=== Done to get channel info of ${channel} with id of org${org}/peer${peer} === "
  fi
}

# Fetch all blocks for a channel
# Usage: channelFetchAll channel org peer orderer_url orderer_tls_rootcert
channelFetchAll() {
  local channel=$1
  local org=$2
  local peer=$3
  local orderer_url=$4
  local orderer_tls_rootcert=$5

  echo "=== Fetch all block for channel $channel === "

  local block_file=/tmp/${channel}_newest.block
  channelFetch ${channel} $org $peer ${orderer_url} ${orderer_tls_rootcert} "newest" ${block_file}
  [ $? -ne 0 ] && exit 1
  newest_block_shasum=$(getShaSum ${block_file})
  echo "fetch newest block ${block_file} with shasum=${newest_block_shasum}"

  block_file=${CHANNEL_ARTIFACTS}/${channel}_config.block
  channelFetch ${channel} $org $peer ${orderer_url} ${orderer_tls_rootcert} "config" ${block_file}
  [ $? -ne 0 ] && exit 1
  echo "fetch config block ${block_file}"

  for i in $(# we at most fetch 16 blocks
    seq 0 16
  ); do
    block_file=${CHANNEL_ARTIFACTS}/${channel}_${i}.block
    channelFetch ${channel} $org $peer ${orderer_url} ${orderer_tls_rootcert} $i ${block_file}
    [ $? -ne 0 ] && exit 1
    [ -f $block_file ] || break
    echo "fetch block $i and saved into ${block_file}"
    block_shasum=$(getShaSum ${block_file})
    [ ${block_shasum} = ${newest_block_shasum} ] && {
      echo "Block $i is the last one for channel $channel"
      break
    }
  done
}

# Fetch some block from a given channel
# channelFetch channel org peer orderer_url blockNum block_file
channelFetch() {
  local channel=$1
  local org=$2
  local peer=$3
  local orderer_url=$4
  local orderer_tls_rootcert=$5
  local num=$6
  local block_file=$7
  echo "=== Fetch block $num of channel $channel === "

  #setEnvs $org $peer
  setOrdererEnvs # system channel required id from ordererOrg
  # while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
  # lets supply it directly as we know it using the "-o" option
  if [ -z "${CORE_PEER_TLS_ENABLED}" ] || [ "${CORE_PEER_TLS_ENABLED}" = "false" ]; then
    peer channel fetch $num ${block_file} \
      -o ${orderer_url} \
      -c ${channel} \
      >"$RUN_LOG_FILE" 2>&1
  else
    peer channel fetch $num ${block_file} \
      -o ${orderer_url} \
      -c ${channel} \
      --tls \
      --cafile ${orderer_tls_rootcert} \
      >"$RUN_LOG_FILE" 2>&1
  fi
  if [ $? -ne 0 ]; then
    cat "$RUN_LOG_FILE"
    echo_r "Fetch block $num of channel $channel failed"
    return 1
  else
    echo "=== Fetch block $num of channel $channel OK === "
    return 0
  fi
}

# Sign a channel config tx
# Usage: channelSignConfigTx channel org peer transaction
channelSignConfigTx() {
  local channel=$1
  local org=$2
  local peer=$3
  local tx=$4
  [ -z $channel ] && [ -z $tx ] && [ -z $org ] && [ -z $peer ] && echo_r "input param invalid" && exit -1
  echo "=== Sign channel config tx $tx for channel $channel by org $org/peer $peer === "
  [ -f ${CHANNEL_ARTIFACTS}/${tx} ] || {
    echo_r "${tx} not exist"
    exit 1
  }

  setEnvs $org $peer

  peer channel signconfigtx -f ${CHANNEL_ARTIFACTS}/${tx} >"$RUN_LOG_FILE" 2>&1
  rc=$?
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  if [ $rc -ne 0 ]; then
    echo_r "Sign channel config tx for channel $channel by org $org/peer $peer failed"
  else
    echo "=== Sign channel config tx channel $channel by org $org/peer $peer is successful === "
  fi
}

# Update a channel config
# Usage: channelUpdate channel org peer orderer_url orderer_tls_rootcert transaction_file
channelUpdate() {
  local channel=$1
  local org=$2
  local peer=$3
  local orderer_url=$4
  local orderer_tls_rootcert=$5
  local tx=$6
  [ -z $channel ] && [ -z $tx ] && [ -z $org ] && [ -z $peer ] && echo_r "input param invalid" && exit -1

  setEnvs $org $peer
  echo "=== Update config on channel ${channel} === "
  [ -f ${CHANNEL_ARTIFACTS}/${tx} ] || {
    echo_r "${tx} not exist"
    exit 1
  }
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    peer channel update \
      -c ${channel} \
      -o ${orderer_url} \
      -f ${CHANNEL_ARTIFACTS}/${tx} \
      >"$RUN_LOG_FILE" 2>&1
  else
    peer channel update \
      -c ${channel} \
      -o ${orderer_url} \
      -f ${CHANNEL_ARTIFACTS}/${tx} \
      --tls \
      --cafile ${orderer_tls_rootcert} \
      >"$RUN_LOG_FILE" 2>&1
  fi
  rc=$?
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult $rc "peer channel update failed"
  echo "=== Channel ${channel} is updated. === "
  sleep 2
}

# Install chaincode on the peer node
# In v2.x it will package, install and approve
# chaincodeInstall peer cc_name version cc_path [lang]
chaincodeInstall() {
  if [ "$#" -ne 7 ]; then
    echo_r "Wrong param number for chaincode install"
    exit -1
  fi
  local org=$1
  local peer=$2
  local peer_url=$3
  local peer_tls_root_cert=$4
  local cc_name=$5
  local version=$6
  local cc_path=$7

  [ -z $org ] && [ -z $peer ] && [ -z $cc_name ] && [ -z $version ] && [ -z $cc_path ] && echo_r "input param invalid" && exit -1
  echo "=== Install Chaincode on org ${org}/peer ${peer} === "
  echo "cc_name=${cc_name}, version=${version}, path=${cc_path}"
  setEnvs $org $peer
  echo "packaging chaincode into tar.gz package"
  local label=${cc_name}
  #local label=${cc_name}_${version}

  echo "packaging chaincode ${cc_name} with path ${cc_path} and label ${label}"
  peer lifecycle chaincode package ${cc_name}.tar.gz \
    --path ${cc_path} \
    --lang golang \
    --label ${label}

  rc=$?
  [ $rc -ne 0 ] && echo "Error in packaging chaincode ${cc_name}" && exit -1

  # v1.x action
  #peer chaincode install \
  #	-n ${cc_name} \
  #	-v $version \
  #	-p ${cc_path} \
  #	>&log.txt

  echo "installing chaincode to peer${peer}/org${org}"
  peer lifecycle chaincode install \
    --peerAddresses ${peer_url} \
    --tlsRootCertFiles ${peer_tls_root_cert} \
    ${cc_name}.tar.gz 2>&1 | tee "$RUN_LOG_FILE"
  rc=${PIPESTATUS[0]}
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"

  verifyResult $rc "Chaincode installation on remote org ${org}/peer$peer has Failed"
  echo "=== Chaincode is installed on org ${org}/peer $peer === "
}

# Install a prebuilt lifecycle package on the peer node.
# chaincodeInstallPackage org peer peer_url peer_tls_root_cert package_file
chaincodeInstallPackage() {
  if [ "$#" -ne 5 ]; then
    echo_r "Wrong param number for chaincode package install"
    exit -1
  fi
  local org=$1
  local peer=$2
  local peer_url=$3
  local peer_tls_root_cert=$4
  local package_file=$5

  [ -f "${package_file}" ] || {
    echo_r "chaincode package not found: ${package_file}"
    exit -1
  }

  echo "=== Install Chaincode package on org ${org}/peer ${peer} === "
  echo "package=${package_file}"
  setEnvs $org $peer

  peer lifecycle chaincode install \
    --peerAddresses ${peer_url} \
    --tlsRootCertFiles ${peer_tls_root_cert} \
    ${package_file} 2>&1 | tee "$RUN_LOG_FILE"
  rc=${PIPESTATUS[0]}
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"

  verifyResult $rc "Chaincode package installation on remote org ${org}/peer$peer has Failed"
  echo "=== Chaincode package is installed on org ${org}/peer $peer === "
}

# Query the installed chaincode
# chaincodeQueryCommitted org peer peer_url peer_tls_root_cert
chaincodeQueryInstalled() {
  if [ "$#" -ne 4 ]; then
    echo_r "Wrong param number for chaincode query installed"
    exit -1
  fi
  local org=$1
  local peer=$2
  local peer_url=$3
  local peer_tls_root_cert=$4

  setEnvs $org $peer

  echo "Query the installed chaincode on peer $peer at $peer_url "
  peer lifecycle chaincode queryinstalled \
    --peerAddresses ${peer_url} \
    --tlsRootCertFiles ${peer_tls_root_cert} \
    --output json \
    --connTimeout "3s" \
    >"$QUERY_LOG_FILE" 2>&1
  rc=$?
  [ $rc -ne 0 ] && cat "$QUERY_LOG_FILE"
  cat "$QUERY_LOG_FILE"
  verifyResult $rc "ChaincodeQueryInstalled Failed: org ${org}/peer$peer"
}

# Get the installed chaincode packages
# chaincodeGetCommitted org peer peer_url peer_tls_root_cert cc_name
chaincodeGetInstalled() {
  if [ "$#" -ne 5 ]; then
    echo_r "Wrong param number for chaincode get installed"
    exit -1
  fi
  local org=$1
  local peer=$2
  local peer_url=$3
  local peer_tls_root_cert=$4
  local cc_name=$5

  setEnvs $org $peer
  echo "querying installed chaincode and get its package id"
  peer lifecycle chaincode queryinstalled >"$QUERY_LOG_FILE" 2>&1
  local label=${cc_name}
  #package_id=$(grep -o "${cc_name}_${version}:[a-z0-9]*" query.log|cut -d ":" -f 2)
  package_id=$(grep -o "${label}:[a-z0-9]*" "$QUERY_LOG_FILE")

  echo "Get the installed chaincode package with id= ${package_id} on peer $peer at $peer_url "
  peer lifecycle chaincode getinstalledpackage \
    --peerAddresses ${peer_url} \
    --tlsRootCertFiles ${peer_tls_root_cert} \
    --package-id ${package_id} \
    --output-directory ./ \
    --output json \
    --connTimeout "3s"
  rc=$?
  [ $rc -ne 0 ] && cat "$QUERY_LOG_FILE"
  cat "$QUERY_LOG_FILE"
  verifyResult $rc "ChaincodeGetInstalled Failed: org ${org}/peer$peer"
}

# Approve the chaincode definition
# chaincodeApproveForMyOrg channel org peer peer_url peer_tls_root_cert orderer_url orderer_tls_rootcert channel cc_name version
chaincodeApproveForMyOrg() {
  if [ "$#" -ne 9 -a "$#" -ne 11 ]; then
    echo_r "Wrong param number for chaincode approve"
    exit -1
  fi
  local org=$1
  local peer=$2
  local peer_url=$3
  local peer_tls_root_cert=$4
  local orderer_url=$5
  local orderer_tls_rootcert=$6
  local channel=$7
  local cc_name=$8
  local version=$9
  local collection_config=""                            # collection config file path for sideDB
  local policy="OR ('Org1MSP.member','Org2MSP.member')" # endorsement policy

  if [ ! -z "${10}" ]; then
    collection_config=${10}
  fi

  if [ ! -z "${11}" ]; then
    policy=${11}
  fi

  setEnvs $org $peer
  echo "querying installed chaincode and get its package id"
  peer lifecycle chaincode queryinstalled >"$QUERY_LOG_FILE" 2>&1
  cat "$QUERY_LOG_FILE"
  local label=${cc_name}
  #package_id=$(grep -o "${cc_name}_${version}:[a-z0-9]*" query.log|cut -d ":" -f 2)
  package_id=$(grep -o "${label}:[a-z0-9]*" "$QUERY_LOG_FILE")
  echo "Approve package id=${package_id} by Org ${org}/Peer ${peer}"

  # use the --init-required flag to request the ``Init`` function be invoked to initialize the chaincode
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    peer lifecycle chaincode approveformyorg \
      --peerAddresses ${peer_url} \
      --channelID ${channel} \
      --name ${cc_name} \
      --version ${version} \
      --init-required \
      --package-id ${package_id} \
      --sequence 1 \
      --signature-policy "${policy}" \
      --waitForEvent=false \
      --orderer ${orderer_url} >"$RUN_LOG_FILE" 2>&1
  else
    peer lifecycle chaincode approveformyorg \
      --peerAddresses ${peer_url} \
      --tlsRootCertFiles ${peer_tls_root_cert} \
      --channelID ${channel} \
      --name ${cc_name} \
      --version ${version} \
      --init-required \
      --package-id ${package_id} \
      --sequence 1 \
      --signature-policy "${policy}" \
      --waitForEvent=false \
      --orderer ${orderer_url} \
      --tls true \
      --cafile ${orderer_tls_rootcert} >"$RUN_LOG_FILE" 2>&1
  fi

  rc=$?
  if [ $rc -ne 0 ] && grep -Eq "attempted to redefine uncommitted sequence \(1\) for namespace ${cc_name} with unchanged content|attempted to redefine the current committed sequence \(1\) for namespace ${cc_name}" "$RUN_LOG_FILE"; then
    echo_y "Chaincode ${cc_name} is already approved on org ${org}/peer${peer}; continuing."
    rc=0
  fi
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult $rc "Chaincode Approval on remote org ${org}/peer$peer has Failed"

  waitForChaincodeApproval "$org" "$peer" "${peer_url}" "${peer_tls_root_cert}" "${channel}" "${cc_name}" 1
  echo "=== Chaincode is approved on remote peer$peer === "
}

# Wait until the local org can query its approved definition on the peer.
# waitForChaincodeApproval org peer peer_url peer_tls_root_cert channel cc_name sequence
waitForChaincodeApproval() {
  if [ "$#" -ne 7 ]; then
    echo_r "Wrong param number for waiting chaincode approval"
    exit -1
  fi
  local org=$1
  local peer=$2
  local peer_url=$3
  local peer_tls_root_cert=$4
  local channel=$5
  local cc_name=$6
  local sequence=$7
  local max_wait=${TIMEOUT:-30}

  setEnvs $org $peer
  for _ in $(seq 1 ${max_wait}); do
    peer lifecycle chaincode queryapproved \
      --peerAddresses ${peer_url} \
      --tlsRootCertFiles ${peer_tls_root_cert} \
      --channelID ${channel} \
      --name ${cc_name} \
      --sequence ${sequence} \
      --output json >"$RUN_LOG_FILE" 2>&1 && return 0
    sleep 1
  done

  cat "$RUN_LOG_FILE"
  echo_r "Timed out waiting for chaincode approval on org ${org}/peer${peer}"
  exit 1
}

# Query the Approved chaincode definition
# chaincodeQueryApproved org peer peer_url peer_tls_root_cert channel cc_name sequence
chaincodeQueryApproved() {
  if [ "$#" -ne 7 ]; then
    echo_r "Wrong param number for chaincode queryapproved"
    exit -1
  fi
  local org=$1
  local peer=$2
  local peer_url=$3
  local peer_tls_root_cert=$4
  local channel=$5
  local cc_name=$6
  local sequence=$7

  setEnvs $org $peer

  echo "Query the approved chaincode definition of $cc_name sequence ${sequence} with ${peer_url} "
  env | grep CORE_PEER
  peer lifecycle chaincode queryapproved \
    --peerAddresses ${peer_url} \
    --tlsRootCertFiles ${peer_tls_root_cert} \
    --channelID ${channel} \
    --name ${cc_name} \
    --sequence ${sequence} \
    --output json >"$RUN_LOG_FILE" 2>&1

  rc=$?
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult $rc "ChaincodeQueryApproved Failed: org ${org}/peer$peer"
}

# Check the commitReadiness of the chaincode definition
# chaincodeCheckCommitReadiness channel org peer cc_name version sequence
chaincodeCheckCommitReadiness() {
  if [ "$#" -ne 8 ]; then
    echo_r "Wrong param number for chaincode queryapproval"
    exit -1
  fi
  local org=$1
  local peer=$2
  local peer_url=$3
  local peer_tls_root_cert=$4
  local channel=$5
  local cc_name=$6
  local version=$7
  local sequence=$8

  setEnvs $org $peer

  echo "checkcommitreadiness with chaincode $cc_name $version $sequence"
  peer lifecycle chaincode checkcommitreadiness \
    --peerAddresses ${peer_url} \
    --tlsRootCertFiles ${peer_tls_root_cert} \
    --channelID ${channel} \
    --name ${cc_name} \
    --output json \
    --version ${version} \
    --sequence ${sequence} >"$RUN_LOG_FILE" 2>&1

  rc=$?
  if [ $rc -ne 0 ] && grep -q "requested sequence is ${sequence}, but new definition must be sequence $((sequence + 1))" "$RUN_LOG_FILE"; then
    echo_y "Chaincode ${cc_name} sequence ${sequence} is already committed on channel ${channel}; continuing."
    rc=0
  fi
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult $rc "ChaincodeQueryApproval Failed: org ${org}/peer$peer"
}

# Anyone can commit the chaincode definition once it's approved by major
# chaincodeCommit org peer channel orderer_url orderer_tls_rootcert cc_name version [collection-config] [endorse-policy]
chaincodeCommit() {
  if [ "$#" -ne 7 -a "$#" -ne 9 ]; then
    echo_r "Wrong param number for chaincode commit"
    exit -1
  fi
  local org=$1
  local peer=$2
  local channel=$3
  local orderer_url=$4
  local orderer_tls_rootcert=$5
  local cc_name=$6
  local version=$7
  local collection_config=""                            # collection config file path for sideDB
  local policy="OR ('Org1MSP.member','Org2MSP.member')" # endorsement policy

  if [ ! -z "$8" ]; then
    collection_config=$8
  fi

  if [ ! -z "$9" ]; then
    policy=$9 # chaincode endorsement policy
  fi

  local org1_peer
  local org2_peer
  local org1_peer_url
  local org1_peer_tls_rootcert
  local org2_peer_url
  local org2_peer_tls_rootcert

  setEnvs $org $peer
  echo "querying installed chaincode and get its package id"
  peer lifecycle chaincode queryinstalled >"$QUERY_LOG_FILE" 2>&1
  label=${cc_name}
  #package_id=$(grep -o "${cc_name}_${version}:[a-z0-9]*" query.log|cut -d ":" -f 2)
  package_id=$(grep -o "${label}:[a-z0-9]*" "$QUERY_LOG_FILE")
  echo "package_id=${package_id}"

  org1_peer=$(getOrgTestPeer 1)
  org2_peer=$(getOrgTestPeer 2)
  org1_peer_url=$(getOrgPeerUrl 1 "${org1_peer}")
  org1_peer_tls_rootcert=$(getOrgPeerTlsRootcert 1 "${org1_peer}")
  org2_peer_url=$(getOrgPeerUrl 2 "${org2_peer}")
  org2_peer_tls_rootcert=$(getOrgPeerTlsRootcert 2 "${org2_peer}")

  echo "Committing package id=${package_id} by Org ${org}/Peer ${peer}"
  # use the --init-required flag to request the ``Init`` function be invoked to initialize the chaincode
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    peer lifecycle chaincode commit \
      -o ${orderer_url} \
      --channelID ${channel} \
      --name ${cc_name} \
      --version ${version} \
      --init-required \
      --sequence 1 \
      --peerAddresses ${org1_peer_url} \
      --tlsRootCertFiles ${org1_peer_tls_rootcert} \
      --peerAddresses ${org2_peer_url} \
      --tlsRootCertFiles ${org2_peer_tls_rootcert} \
      --collections-config "${collection_config}" \
      --signature-policy "${policy}" \
      --waitForEvent=false >"$RUN_LOG_FILE" 2>&1
  else
    peer lifecycle chaincode commit \
      -o ${orderer_url} \
      --channelID ${channel} \
      --name ${cc_name} \
      --version ${version} \
      --init-required \
      --sequence 1 \
      --peerAddresses ${org1_peer_url} \
      --tlsRootCertFiles ${org1_peer_tls_rootcert} \
      --peerAddresses ${org2_peer_url} \
      --tlsRootCertFiles ${org2_peer_tls_rootcert} \
      --collections-config "${collection_config}" \
      --signature-policy "${policy}" \
      --waitForEvent=false \
      --tls true \
    --cafile ${orderer_tls_rootcert} >"$RUN_LOG_FILE" 2>&1
  fi
  rc=$?
  if [ $rc -ne 0 ] && grep -q "requested sequence is 1, but new definition must be sequence 2" "$RUN_LOG_FILE"; then
    echo_y "Chaincode ${cc_name} sequence 1 is already committed on channel ${channel}; continuing."
    rc=0
  fi
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult $rc "Chaincode Commit on remote org ${org}/peer$peer has Failed"

  waitForChaincodeCommit "$org" "$peer" "${org1_peer_url}" "${org1_peer_tls_rootcert}" "${channel}" "${cc_name}" 1
  echo "=== Chaincode is committed on channel $channel === "
}

# Wait until the committed definition is visible on a peer.
# waitForChaincodeCommit org peer peer_url peer_tls_root_cert channel cc_name sequence
waitForChaincodeCommit() {
  if [ "$#" -ne 7 ]; then
    echo_r "Wrong param number for waiting chaincode commit"
    exit -1
  fi
  local org=$1
  local peer=$2
  local peer_url=$3
  local peer_tls_root_cert=$4
  local channel=$5
  local cc_name=$6
  local sequence=$7
  local max_wait=${TIMEOUT:-30}

  setEnvs $org $peer
  for _ in $(seq 1 ${max_wait}); do
    peer lifecycle chaincode querycommitted \
      --peerAddresses ${peer_url} \
      --tlsRootCertFiles ${peer_tls_root_cert} \
      --channelID ${channel} \
      --name ${cc_name} \
      --output json >"$RUN_LOG_FILE" 2>&1 || true
    grep -q "\"sequence\": ${sequence}" "$RUN_LOG_FILE" && return 0
    sleep 1
  done

  cat "$RUN_LOG_FILE"
  echo_r "Timed out waiting for chaincode commit on org ${org}/peer${peer}"
  exit 1
}

# Query the Commit the chaincode definition
# chaincodeQueryCommitted org peer peer_url peer_tls_root_cert channel cc_name
chaincodeQueryCommitted() {
  if [ "$#" -ne 6 ]; then
    echo_r "Wrong param number for chaincode querycommit"
    exit -1
  fi
  local org=$1
  local peer=$2
  local peer_url=$3
  local peer_tls_root_cert=$4
  local channel=$5
  local cc_name=$6

  setEnvs $org $peer

  echo "Query the committed status of chaincode $cc_name with ${peer_url} "
  peer lifecycle chaincode querycommitted \
    --peerAddresses ${peer_url} \
    --tlsRootCertFiles ${peer_tls_root_cert} \
    --channelID ${channel} \
    --output json \
    --name ${cc_name} >"$RUN_LOG_FILE" 2>&1

  rc=$?
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult $rc "ChaincodeQueryCommit Failed: org ${org}/peer$peer"
}

# Instantiate chaincode on specifized peer node
# chaincodeInstantiate channel org peer orderer_url cc_name version args
chaincodeInstantiate() {
  echo_r "Legacy 'peer chaincode instantiate' is not supported in the Fabric 3.0 example."
  echo_r "Use the lifecycle flow instead: install -> approveformyorg -> commit -> init."
  return 1
}

# Invoke the Init func of chaincode to start the container
# Usage: chaincodeInit org peer channel orderer cc_name args peer_url peer_org_tlsca
chaincodeInit() {
  if [ "$#" -ne 8 ]; then
    echo_r "Wrong param number for chaincode Init"
    exit -1
  fi
  local org=$1
  local peer=$2
  local channel=$3
  local orderer=$4
  local cc_name=$5
  local args=$6
  local peer_url=$7
  local peer_org_tlsca=$8

  [ -z $channel ] && [ -z $org ] && [ -z $peer ] && [ -z $cc_name ] && [ -z $args ] && echo_r "input param invalid" && exit -1
  echo "=== chaincodeInit to orderer by id of org${org}/peer${peer} === "
  echo "channel=${channel}, cc_name=${cc_name}, args=${args}"
  setEnvs $org $peer
  # while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
  # lets supply it directly as we know it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
  peer chaincode invoke \
      -o ${orderer} \
      --channelID ${channel} \
      --name ${cc_name} \
      --peerAddresses ${peer_url} \
      --tlsRootCertFiles ${peer_org_tlsca} \
      --isInit \
      -c ${args} \
      >"$RUN_LOG_FILE" 2>&1
  else
    peer chaincode invoke \
      -o ${orderer} \
      --channelID ${channel} \
      --name ${cc_name} \
      --peerAddresses ${peer_url} \
      --tlsRootCertFiles ${peer_org_tlsca} \
      --isInit \
      -c ${args} \
      --tls \
      --cafile ${ORDERER0_TLS_CA} \
      >"$RUN_LOG_FILE" 2>&1
  fi
  rc=$?
  if [ $rc -ne 0 ] && grep -q "chaincode '${cc_name}' is already initialized but called as init" "$RUN_LOG_FILE"; then
    echo_y "Chaincode ${cc_name} is already initialized on channel ${channel}; continuing."
    rc=0
  fi
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult $rc "Chaincode Init failed: peer$peer in channel ${channel}"
  echo "=== Chaincode Init done: peer$peer in channel ${channel} === "
}

# Usage: chaincodeInvoke org peer channel orderer cc_name args peer_url peer_org_tlsca
chaincodeInvoke() {
  if [ "$#" -ne 9 ]; then
    echo_r "Wrong param number for chaincode Invoke"
    exit -1
  fi
  local org=$1
  local peer=$2
  local peer_url=$3
  local peer_org_tlsca=$4
  local channel=$5
  local orderer_url=$6
  local orderer_tls_rootcert=$7
  local cc_name=$8
  local args=$9

  [ -z $channel ] && [ -z $org ] && [ -z $peer ] && [ -z $cc_name ] && [ -z $args ] && echo_r "input param invalid" && exit -1
  echo "=== chaincodeInvoke to orderer by id of org${org}/peer${peer} === "
  echo "channel=${channel}, cc_name=${cc_name}, args=${args}"
  setEnvs $org $peer
  # while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
  # lets supply it directly as we know it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    peer chaincode invoke \
      -o ${orderer_url} \
      --channelID ${channel} \
      --name ${cc_name} \
      --peerAddresses ${peer_url} \
      --tlsRootCertFiles ${peer_org_tlsca} \
      -c ${args} \
    >"$RUN_LOG_FILE" 2>&1
  else
    peer chaincode invoke \
      -o ${orderer_url} \
      --channelID ${channel} \
      --name ${cc_name} \
      --peerAddresses ${peer_url} \
      --tlsRootCertFiles ${peer_org_tlsca} \
      -c ${args} \
      --tls \
      --cafile ${orderer_tls_rootcert} \
      >"$RUN_LOG_FILE" 2>&1
  fi
  rc=$?
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult $rc "Invoke execution on peer$peer failed "
  echo "=== Invoke transaction on peer$peer in channel ${channel} is successful === "
}

# query org peer channel cc_name args expected_result
chaincodeQuery() {
  if [ "$#" -ne 7 -a "$#" -ne 8 ]; then
    echo_r "Wrong param number $# for chaincode Query"
    echo $*
    exit -1
  fi
  local org=$1
  local peer=$2
  local peer_url=$3
  local peer_org_tlsca=$4
  local channel=$5
  local cc_name=$6
  local args=$7
  local expected_result=""

  [ $# -eq 8 ] && local expected_result=$8

  [ -z $channel ] && [ -z $org ] && [ -z $peer ] && [ -z $cc_name ] && [ -z $args ] && echo_r "input param invalid" && exit -1

  echo "=== chaincodeQuery to org $org/peer $peer === "
  echo "channel=${channel}, cc_name=${cc_name}, args=${args}, expected_result=${expected_result}"
  local rc=1
  local starttime=$(date +%s)

  setEnvs $org $peer

  # we either get a successful response, or reach TIMEOUT
  while [ "$(($(date +%s) - starttime))" -lt "$TIMEOUT" -a $rc -ne 0 ]; do
    echo "Attempting to Query org ${org}/peer ${peer} ...$(($(date +%s) - starttime)) secs"
    peer chaincode query \
      -C "${channel}" \
      -n "${cc_name}" \
      --peerAddresses ${peer_url} \
      --tlsRootCertFiles ${peer_org_tlsca} \
      -c "${args}" \
      >"$RUN_LOG_FILE" 2>&1
    rc=$?
    if [ -n "${expected_result}" ]; then # need to check the result
      test $? -eq 0 && VALUE=$(cat "$RUN_LOG_FILE" | awk 'END {print $NF}')
      if [ "$VALUE" = "${expected_result}" ]; then
        let rc=0
        echo_b "$VALUE == ${expected_result}, passed"
      else
        let rc=1
        echo_b "$VALUE != ${expected_result}, will retry"
      fi
    fi
    if [ $rc -ne 0 ]; then
      cat "$RUN_LOG_FILE"
      sleep 2
    fi
  done

  # rc==0, or timeout
  if [ $rc -eq 0 ]; then
    echo "=== Query is done: org $org/peer$peer in channel ${channel} === "
  else
    echo_r "=== Query failed: org $org/peer$peer, run $(make stop clean) to clean ==="
    exit 1
  fi
}

# List Installed chaincode on specified peer node, and instantiated chaincodes at specific channel
# chaincodeList org1 peer0 businesschannel
chaincodeList() {
  local org=$1
  local peer=$2
  local channel=$3

  [ -z $org ] && [ -z $peer ] && [ -z $channel ] && echo_r "input param invalid" && exit -1
  echo "=== ChaincodeList on org ${org}/peer ${peer} === "
  setEnvs $org $peer
  echo_b "Get installed chaincodes at peer$peer.org$org"
  peer chaincode list \
    --installed >"$RUN_LOG_FILE" 2>&1
  # \
  #--peerAddresses "peer${peer}.org${org}.example.com" --tls false
  rc=$?
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult $rc "List installed chaincodes on remote org ${org}/peer$peer has Failed"

  echo_b "Get instantiated chaincodes at channel $org"
  peer chaincode list \
    --instantiated \
    -C ${channel} >"$RUN_LOG_FILE" 2>&1
  rc=$?
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult $rc "List installed chaincodes on remote org ${org}/peer$peer has Failed"
  echo "=== ChaincodeList is done at peer${peer}.org${org} === "
}

# Start chaincode with dev mode
# TODO: use variables instead of hard-coded value
chaincodeStartDev() {
  local peer=$1
  local version=$2
  [ -z $peer ] && [ -z $version ] && echo_r "input param invalid" && exit -1
  setEnvs 1 0
  CORE_CHAINCODE_LOGLEVEL=debug \
    CORE_PEER_ADDRESS=peer${peer}.org1.example.com:7052 \
    CORE_CHAINCODE_ID_NAME=${CC_02_NAME}:${version} \
    nohup ./scripts/chaincode_example02 >chaincode_dev.log &
  rc=$?
  [ $rc -ne 0 ] && cat "$RUN_LOG_FILE"
  verifyResult $rc "Chaincode start in dev mode has Failed"
  echo "=== Chaincode started in dev mode === "
}

# chaincodeUpgrade channel org peer orderer_url cc_name version args
chaincodeUpgrade() {
  echo_r "Legacy 'peer chaincode upgrade' is not supported in the Fabric 3.0 example."
  echo_r "Use lifecycle sequence updates instead: install -> approveformyorg -> commit."
  return 1
}

# configtxlator encode json to pb
# Usage: configtxlatorEncode msgType input output
configtxlatorEncode() {
  local msgType=$1
  local input=$2
  local output=$3

  echo "Encode $input --> $output using type $msgType"
  docker exec ${CTL_CONTAINER} configtxlator proto_encode \
    --type=${msgType} \
    --input=${input} \
    --output=${output}

  #curl -sX POST \
  #		--data-binary @${input} \
  #		${CTL_ENCODE_URL}/${msgType} \
  #		>${output}
}

# configtxlator decode pb to json
# Usage: configtxlatorEncode msgType input output
configtxlatorDecode() {
  local msgType=$1
  local input=$2
  local output=$3

  echo "Config Decode $input --> $output using type $msgType"
  if [ ! -f $input ]; then
    echo_r "input file not found"
    exit 1
  fi

  docker exec ${CTL_CONTAINER} configtxlator proto_decode \
    --type=${msgType} \
    --input=${input} \
    --output=${output}

  #curl -sX POST \
  #	--data-binary @"${input}" \
  #	"${CTL_DECODE_URL}/${msgType}" \
  #	> "${output}"
}

# compute diff between two pb
# Usage: configtxlatorCompare channel origin updated output
configtxlatorCompare() {
  local channel=$1
  local origin=$2
  local updated=$3
  local output=$4

  echo "Config Compare $origin vs $updated > ${output} in channel $channel"
  if [ ! -f $origin ] || [ ! -f $updated ]; then
    echo_r "input file not found"
    exit 1
  fi

  docker exec ${CTL_CONTAINER} configtxlator compute_update \
    --original=${origin} \
    --updated=${updated} \
    --channel_id=${channel} \
    --output=${output}

  #curl -sX POST \
  #	-F channel="${channel}" \
  #	-F "original=@${origin}" \
  #	-F "updated=@${updated}" \
  #	"${CTL_COMPARE_URL}" \
  #	> "${output}"

  [ $? -eq 0 ] || echo_r "Failed to compute config update"
}

# Run cmd inside the config generator container
gen_con_exec() {
  docker exec $GEN_CONTAINER "$@"
}
