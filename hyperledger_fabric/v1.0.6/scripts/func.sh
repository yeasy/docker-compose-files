#!/usr/bin/env bash

echo_r () {
    [ $# -ne 1 ] && return 0
    echo -e "\033[31m$1\033[0m"
}
echo_g () {
    [ $# -ne 1 ] && return 0
    echo -e "\033[32m$1\033[0m"
}
echo_y () {
    [ $# -ne 1 ] && return 0
    echo -e "\033[33m$1\033[0m"
}
echo_b () {
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

# Verify $1 is not 0, then output error msg $2 and exit
verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo "$2"
		echo_r "=== ERROR !!! FAILED to execute End-2-End Scenario ==="
		exit 1
	fi
}

# set env to use orderOrg's identity
setOrdererEnvs () {
	export CORE_PEER_LOCALMSPID="OrdererMSP"
	export CORE_PEER_MSPCONFIGPATH=${ORDERER_ADMIN_MSP}
	export CORE_PEER_TLS_ROOTCERT_FILE=${ORDERER_TLS_ROOTCERT}
	#t="\${ORG${org}_PEER${peer}_URL}" && CORE_PEER_ADDRESS=`eval echo $t`
}

# Set global env variables for fabric cli, after setting:
# client is the admin as given org
# TLS root cert is configured to given peer's
# remote peer address is configured to given peer's
# CORE_PEER_LOCALMSPID=Org1MSP
# CORE_PEER_ADDRESS=peer0.org1.example.com:7051
# CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
# CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
# Usage: setEnvs org peer
setEnvs () {
	local org=$1  # 1 or 2
	local peer=$2  # 0 or 1
	[ -z $org ] && [ -z $peer ] && echo_r "input param invalid" && exit -1

	local t=""
	export CORE_PEER_LOCALMSPID="Org${org}MSP"
	#CORE_PEER_MSPCONFIGPATH=\$${ORG${org}_ADMIN_MSP}
	t="\${ORG${org}_PEER${peer}_URL}" && export CORE_PEER_ADDRESS=`eval echo $t`
	t="\${ORG${org}_ADMIN_MSP}" && export CORE_PEER_MSPCONFIGPATH=`eval echo $t`
	t="\${ORG${org}_PEER${peer}_TLS_ROOTCERT}" && export CORE_PEER_TLS_ROOTCERT_FILE=`eval echo $t`

	#env |grep CORE
}

checkOSNAvailability() {
	#Use orderer's MSP for fetching system channel config block
	export CORE_PEER_LOCALMSPID="OrdererMSP"
	export CORE_PEER_TLS_ROOTCERT_FILE=${ORDERER_TLS_CA}
	export CORE_PEER_MSPCONFIGPATH=${ORDERER_MSP}

	local rc=1
	local starttime=$(date +%s)

	# continue to poll
	# we either get a successful response, or reach TIMEOUT
	while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
	do
		 sleep 3
		 echo "Attempting to fetch system channel ...$(($(date +%s)-starttime)) secs"
		 if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
			 peer channel fetch 0 -o ${ORDERER_URL} -c "testchainid" >&log.txt
		 else
			 peer channel fetch 0 -o ${ORDERER_URL} -c "testchainid" --tls --cafile ${ORDERER_TLS_CA} >&log.txt
		 fi
		 test $? -eq 0 && VALUE=$(cat log.txt | awk '/Received block/ {print $NF}')
		 test "$VALUE" = "0" && let rc=0
	done
	[ $rc -ne 0 ] && cat log.txt
	verifyResult $rc "Ordering Service is not available, Please try again ..."
	echo "=== Ordering Service is up and running === "
	echo
}

# Internal func called by channelCreate
channelCreateAction(){
	local channel=$1
	local channel_tx=$2
	if [ -z "$CORE_PEER_TLS_ENABLED" ] || [ "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel create \
			-o ${ORDERER_URL} \
			-c ${channel} \
			-f ${CHANNEL_ARTIFACTS}/${channel_tx} \
			--timeout $TIMEOUT \
			>&log.txt
	else
		peer channel create \
			-o ${ORDERER_URL} \
			-c ${channel} \
			-f ${CHANNEL_ARTIFACTS}/${channel_tx} \
			--timeout $TIMEOUT \
			--tls \
			--cafile ${ORDERER_TLS_CA} \
			>&log.txt
	fi
	return $?
}

# Use peer0/org1 to create a channel
# channelCreate APP_CHANNEL APP_CHANNEL.tx org peer
channelCreate() {
	local channel=$1
	local tx=$2
	local org=$3
	local peer=$4

	[ -z $channel ] && [ -z $tx ] && [ -z $org ] && [ -z $peer ] && echo_r "input param invalid" && exit -1

	echo "=== Create Channel ${channel} by org $org/peer $peer === "
	setEnvs $org $peer
	local rc=1
	local counter=0
	while [ ${counter} -lt ${MAX_RETRY} -a ${rc} -ne 0 ]; do
		 channelCreateAction "${channel}" "${tx}"
		 rc=$?
		 let counter=${counter}+1
		 #COUNTER=` expr $COUNTER + 1`
		 [ $rc -ne 0 ] && echo "Failed to create channel $channel, retry after 3s" && sleep 3
	done
	[ $rc -ne 0 ] && cat log.txt
	verifyResult ${rc} "Channel ${channel} creation failed"
	echo "=== Channel ${channel} is created. === "
}

# called by channelJoinWithRetry
channelJoinAction () {
	local channel=$1
	peer channel join \
		-b ${channel}.block \
		>&log.txt
}

## Sometimes Join takes time hence RETRY atleast for 5 times
channelJoinWithRetry () {
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
	[ $rc -ne 0 ] && cat log.txt
  verifyResult ${rc} "After $MAX_RETRY attempts, peer${peer} failed to Join the Channel"
}

# Join given (by default all) peers into the channel
# channelJoin channel org peer
channelJoin () {
	local channel=$1
	local org=$2
	local peer=$3
	[ -z $channel ] && [ -z $org ] && [ -z $peer ] && echo_r "input param invalid" && exit -1

	echo "=== Join org $org/peer $peer into channel ${channel} === "
	setEnvs $org $peer
	channelJoinWithRetry ${channel} $peer
	echo "=== org $org/peer $peer joined into channel ${channel} === "
}

getShasum () {
	[ ! $# -eq 1 ] && exit 1
	shasum ${1} | awk '{print $1}'
}

# Fetch all blocks for a channel
# Usage: channelFetchAll channel org peer
channelFetchAll () {
	local channel=$1
	local org=$2
	local peer=$3

	echo "=== Fetch all block for channel $channel === "

	local block_file=/tmp/${channel}_newest.block
	channelFetch ${channel} $org $peer "newest" ${block_file}
	[ $? -ne 0 ] && exit 1
	newest_block_shasum=$(getShasum ${block_file})
	echo "fetch newest block ${block_file} with shasum=${newest_block_shasum}"

	block_file=${CHANNEL_ARTIFACTS}/${channel}_config.block
	channelFetch ${channel} $org $peer "config" ${block_file}
	[ $? -ne 0 ] && exit 1
	echo "fetch config block ${block_file}"

	for i in $(seq 0 16); do  # we at most fetch 16 blocks
		block_file=${CHANNEL_ARTIFACTS}/${channel}_${i}.block
		channelFetch ${channel} $org $peer $i ${block_file}
		[ $? -ne 0 ] && exit 1
		[ -f $block_file ] || break
		echo "fetch block $i and saved into ${block_file}"
		block_shasum=$(getShasum ${block_file})
		[ ${block_shasum} = ${newest_block_shasum} ] && { echo "Block $i is the last one for channel $channel"; break; }
	done
}

# Fetch some block from a given channel: channel, peer, blockNum
channelFetch () {
	local channel=$1
	local org=$2
	local peer=$3
	local num=$4
	local block_file=$5
	echo "=== Fetch block $num of channel $channel === "

	#setEnvs $org $peer
	setOrdererEnvs  # system channel required id from ordererOrg
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "${CORE_PEER_TLS_ENABLED}" ] || [ "${CORE_PEER_TLS_ENABLED}" = "false" ]; then
		peer channel fetch $num ${block_file} \
			-o ${ORDERER_URL} \
			-c ${channel}  \
			>&log.txt
	else
		peer channel fetch $num ${block_file} \
			-o ${ORDERER_URL} \
			-c ${channel} \
			--tls \
			--cafile ${ORDERER_TLS_CA}  \
			>&log.txt
	fi
	if [ $? -ne 0 ]; then
		cat log.txt
		echo_r "Fetch block $num of channel $channel failed"
		return 1
	else
		echo "=== Fetch block $num of channel $channel OK === "
		return 0
	fi
}

# Sign a channel config tx
# Usage: channelSignConfigTx channel org peer transaction
channelSignConfigTx () {
	local channel=$1
	local org=$2
	local peer=$3
	local tx=$4
	[ -z $channel ] && [ -z $tx ] && [ -z $org ] && [ -z $peer ] && echo_r "input param invalid" && exit -1
	echo "=== Sign channel config tx $tx for channel $channel by org $org/peer $peer === "
	[ -f ${CHANNEL_ARTIFACTS}/${tx} ] || { echo_r "${tx} not exist"; exit 1; }

	setEnvs $org $peer

	peer channel signconfigtx -f ${CHANNEL_ARTIFACTS}/${tx} >&log.txt
	rc=$?
	[ $rc -ne 0 ] && cat log.txt
	if [ $rc -ne 0 ]; then
		echo_r "Sign channel config tx for channel $channel by org $org/peer $peer failed"
	else
		echo "=== Sign channel config tx channel $channel by org $org/peer $peer is successful === "
	fi
}

# Update a channel config
# Usage: channelUpdate channel org peer transaction_file
channelUpdate() {
	local channel=$1
  local org=$2
  local peer=$3
  local tx=$4
	[ -z $channel ] && [ -z $tx ] && [ -z $org ] && [ -z $peer ] && echo_r "input param invalid" && exit -1

  setEnvs $org $peer
	echo "=== Update config on channel ${channel} === "
	[ -f ${CHANNEL_ARTIFACTS}/${tx} ] || { echo_r "${tx} not exist"; exit 1; }
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel update \
		-o ${ORDERER_URL} \
		-c ${channel} \
		-f ${CHANNEL_ARTIFACTS}/${tx} \
		>&log.txt
	else
		peer channel update \
		-o ${ORDERER_URL} \
		-c ${channel} \
		-f ${CHANNEL_ARTIFACTS}/${tx} \
		--tls \
		--cafile ${ORDERER_TLS_CA} \
		>&log.txt
	fi
	rc=$?
	[ $rc -ne 0 ] && cat log.txt
	verifyResult $rc "peer channel update failed"
	echo "=== Channel ${channel} is updated. === "
	sleep 2
}

# Install chaincode on specified peer node
# chaincodeInstall peer cc_name version path
chaincodeInstall () {
	local org=$1
	local peer=$2
	local name=$3
	local version=$4
	local path=$5
	[ -z $org ] && [ -z $peer ] && [ -z $name ] && [ -z $version ] && [ -z $path ] &&  echo_r "input param invalid" && exit -1
	echo "=== Install Chaincode $name:$version ($path) on org ${org}/peer $peer === "
	setEnvs $org $peer
	peer chaincode install \
		-n ${name} \
		-v $version \
		-p ${path} \
		>&log.txt
	rc=$?
	[ $rc -ne 0 ] && cat log.txt
  verifyResult $rc "Chaincode installation on remote org ${org}/peer$peer has Failed"
	echo "=== Chaincode is installed on remote peer$peer === "
}

# Instantiate chaincode on specifized peer node
# chaincodeInstantiate channel org peer name version args
chaincodeInstantiate () {
	local channel=$1
	local org=$2
	local peer=$3
	local name=$4
	local version=$5
	local args=$6
	[ -z $channel ] && [ -z $org ] && [ -z $peer ] && [ -z $name ] && [ -z $version ] && [ -z $args ] &&  echo_r "input param invalid" && exit -1
	setEnvs $org $peer
	echo "=== chaincodeInstantiate for channel ${channel} on org $org/peer $peer ===="
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode instantiate \
			-o ${ORDERER_URL} \
			-C ${channel} \
			-n ${name} \
			-v ${version} \
			-c ${args} \
			-P "OR	('Org1MSP.member','Org2MSP.member')" \
			>&log.txt
	else
		peer chaincode instantiate \
			-o ${ORDERER_URL} \
			-C ${channel} \
			-n ${name} \
			-v ${version} \
			-c ${args} \
			-P "OR	('Org1MSP.member','Org2MSP.member')" \
			--tls \
			--cafile ${ORDERER_TLS_CA} \
			>&log.txt
	fi
	rc=$?
	[ $rc -ne 0 ] && cat log.txt
	verifyResult $rc "ChaincodeInstantiation on org $org/peer$peer in channel ${channel} failed"
	echo "=== Chaincode Instantiated in channel ${channel} by peer$peer ==="
}


# Usage: chaincodeInvoke channel org peer name args
chaincodeInvoke () {
	local channel=$1
	local org=$2
	local peer=$3
	local name=$4
	local args=$5
	[ -z $channel ] && [ -z $org ] && [ -z $peer ] && [ -z $name ] && [ -z $args ] &&  echo_r "input param invalid" && exit -1
	echo "=== Invoke transaction on peer$peer in channel ${channel} === "
	setEnvs $org $peer
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode invoke \
			-o ${ORDERER_URL} \
			-C ${channel} \
			-n ${name} \
			-c ${args} \
			>&log.txt
	else
		peer chaincode invoke \
			-o ${ORDERER_URL} \
			-C ${channel} \
			-n ${name} \
			-c ${args} \
			--tls \
			--cafile ${ORDERER_TLS_CA} \
			>&log.txt
	fi
	rc=$?
	[ $rc -ne 0 ] && cat log.txt
	verifyResult $rc "Invoke execution on peer$peer failed "
	echo "=== Invoke transaction on peer$peer in channel ${channel} is successful === "
}

# query channel peer name args expected_result
chaincodeQuery () {
  local channel=$1
  local org=$2
  local peer=$3
  local name=$4
  local args=$5
	[ -z $channel ] && [ -z $org ] && [ -z $peer ] && [ -z $name ] && [ -z $args ] &&  echo_r "input param invalid" && exit -1
  [ $# -gt 5 ] && local expected_result=$6
  echo "=== Querying on org $org/peer $peer in channel ${channel}... === "
  local rc=1
  local starttime=$(date +%s)

  setEnvs $org $peer
  # we either get a successful response, or reach TIMEOUT
  while [ "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0 ]; do
     echo "Attempting to Query org ${org}/peer ${peer} ...$(($(date +%s)-starttime)) secs"
     peer chaincode query \
			 -C "${channel}" \
			 -n "${name}" \
			 -c "${args}" \
			 >&log.txt
		 rc=$?
		 if [ $# -gt 5 ]; then # need to check the result
			 test $? -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
			 if [ "$VALUE" = "${expected_result}" ]; then
				 let rc=0
			 else
				 let rc=1
				 echo_b "$VALUE != ${expected_result}, will retry"
			 fi
			fi
			if [ $rc -ne 0 ]; then
				 cat log.txt
				 sleep 2
			fi
  done

  # rc==0, or timeout
  if [ $rc -eq 0 ]; then
		echo "=== Query on peer$peer in channel ${channel} is successful === "
  else
		echo_r "=== Query result on peer$peer is INVALID, run `make stop clean` to clean ==="
		exit 1
  fi
}


# Start chaincode with dev mode
# TODO: use variables instead of hard-coded value
chaincodeStartDev () {
	local peer=$1
	local version=$2
	[ -z $peer ] && [ -z $version ] &&  echo_r "input param invalid" && exit -1
	setEnvs 1 0
	CORE_CHAINCODE_LOGLEVEL=debug \
	CORE_PEER_ADDRESS=peer${peer}.org1.example.com:7052 \
	CORE_CHAINCODE_ID_NAME=${CC_02_NAME}:${version} \
	nohup ./scripts/chaincode_example02 > chaincode_dev.log &
	rc=$?
	[ $rc -ne 0 ] && cat log.txt
	verifyResult $rc "Chaincode start in dev mode has Failed"
	echo "=== Chaincode started in dev mode === "
}

# chaincodeUpgrade channel peer name version args
chaincodeUpgrade () {
	local channel=$1
	local org=$2
	local peer=$3
	local name=$4
	local version=$5
	local args=$6
	[ -z $channel ] && [ -z $org ] && [ -z $peer ] && [ -z $name ] && [ -z $version ] && [ -z $args ] &&  echo_r "input param invalid" && exit -1
	echo "=== Upgrade chaincode to version $version on org ${org}/peer $peer in channel ${channel}  === "

	setEnvs $org $peer
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode upgrade \
		-o ${ORDERER_URL} \
		-C ${channel} \
		-n ${name} \
		-v ${version} \
		-c ${args} \
		>&log.txt
	else
		peer chaincode upgrade \
		-o ${ORDERER_URL} \
		-C ${channel} \
		-n ${name} \
		-v ${version} \
		-c ${args} \
		--tls \
		--cafile ${ORDERER_TLS_CA} \
		>&log.txt
	fi
	rc=$?
	[ $rc -ne 0 ] && cat log.txt
	verifyResult $rc "Upgrade execution on peer$peer failed "
	echo "=== Upgrade transaction on peer$peer in channel ${channel} is successful === "
}

# configtxlator encode json to pb
# Usage: configtxlatorEncode msgType input output
configtxlatorEncode() {
	local msgType=$1
	local input=$2
	local output=$3

	echo "Encode $input --> $output using type $msgType"
	curl -sX POST \
			--data-binary @${input} \
			${CTL_ENCODE_URL}/${msgType} \
			>${output}
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

	curl -sX POST \
		--data-binary @"${input}" \
		"${CTL_DECODE_URL}/${msgType}" \
		> "${output}"
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

	curl -sX POST \
		-F channel="${channel}" \
		-F "original=@${origin}" \
		-F "updated=@${updated}" \
		"${CTL_COMPARE_URL}" \
		> "${output}"

	[ $? -eq 0 ] || echo_r "Failed to compute config update"
}

# Run cmd inside the config generator container
gen_con_exec() {
	docker exec -it $GEN_CONTAINER "$@"
}