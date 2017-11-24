#!/bin/bash

# Some useful functions for cc testing

# Detecting whether can import the header file to render colorful cli output
if [ -f ./header.sh ]; then
 source ./header.sh
elif [ -f scripts/header.sh ]; then
 source scripts/header.sh
else
 alias echo_r="echo"
 alias echo_g="echo"
 alias echo_b="echo"
fi

# Define those global variables
if [ -f ./variables.sh ]; then
 source ./variables.sh
elif [ -f scripts/variables.sh ]; then
 source scripts/variables.sh
fi

# Verify $1 is not 0, then output error msg $2 and exit
verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo_b "$2"
		echo_r "=== ERROR !!! FAILED to execute End-2-End Scenario ==="
		exit 1
	fi
}

# Set global env variables for fabric usage
# Usage: setEnvs org peer
setEnvs () {
	set -x
	local org=$1  # 1 or 2
	local peer=$2  # 0 or 1
	local t=""
	CORE_PEER_LOCALMSPID="Org${org}MSP"
	#CORE_PEER_MSPCONFIGPATH=\$${ORG${org}_ADMIN_MSP}
	t="\${ORG${org}_ADMIN_MSP}" && CORE_PEER_MSPCONFIGPATH=`eval echo $t`
	t="\${ORG${org}_PEER${peer}_TLS_ROOTCERT}" && CORE_PEER_TLS_ROOTCERT_FILE=`eval echo $t`
	t="\${ORG${org}_PEER${peer}_URL}" && CORE_PEER_ADDRESS=`eval echo $t`

	env |grep CORE
}

checkOSNAvailability() {
	#Use orderer's MSP for fetching system channel config block
	CORE_PEER_LOCALMSPID="OrdererMSP"
	CORE_PEER_TLS_ROOTCERT_FILE=${ORDERER_TLS_CA}
	CORE_PEER_MSPCONFIGPATH=${ORDERER_MSP}

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
			 peer channel fetch 0 -o ${ORDERER_URL} -c "testchainid" --tls $CORE_PEER_TLS_ENABLED --cafile ${ORDERER_TLS_CA} >&log.txt
		 fi
		 test $? -eq 0 && VALUE=$(cat log.txt | awk '/Received block/ {print $NF}')
		 test "$VALUE" = "0" && let rc=0
	done
	cat log.txt
	verifyResult $rc "Ordering Service is not available, Please try again ..."
	echo "=== Ordering Service is up and running === "
	echo
}

# Internal func called by channelCreate
channelCreateAction(){
	local channel=$1
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel create \
			-o ${ORDERER_URL} \
			-c ${channel} \
			-f ./channel-artifacts/channel.tx \
			--timeout $TIMEOUT \
			>&log.txt
	else
		peer channel create \
			-o ${ORDERER_URL} \
			-c ${channel} \
			-f ./channel-artifacts/channel.tx \
			--timeout $TIMEOUT \
			--tls $CORE_PEER_TLS_ENABLED \
			--cafile ${ORDERER_TLS_CA} \
			>&log.txt
	fi
	return $?
}

# Use peer0/org1 to create a channel
# channelCreate channel_name
channelCreate() {
	local channel=$1
	echo_b "=== Create Channel ${channel} === "
	local counter=0
	#setEnvs 0
	channelCreateAction ${channel}
	local res=$?
	while [ ${counter} -lt ${MAX_RETRY} -a ${res} -ne 0 ]; do
		 echo_b "Failed to create channel $channel, retry after 3s"
		 sleep 3
		 channelCreateAction ${channel}
		 res=$?
		 let counter=${counter}+1
		 #COUNTER=` expr $COUNTER + 1`
	done
	cat log.txt
	verifyResult ${res} "Channel ${channel} creation failed"
	echo_g "=== Channel ${channel} is created. === "
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
	local res=$?
	while [ ${counter} -lt ${MAX_RETRY} -a ${res} -ne 0 ]; do
		echo_b "peer${peer} failed to join channel ${channel}, retry after 2s"
		sleep 2
		channelJoinAction ${channel}
		res=$?
		let counter=${counter}+1
	done
	cat log.txt
  verifyResult ${res} "After $MAX_RETRY attempts, peer${peer} failed to Join the Channel"
}

# Join given (by default all) peers into the channel
# channelJoin 0 1 2 3
channelJoin () {
	local channel=$1
	echo_b "=== Join peers into channel ${channel} === "
	peers_to_join=$(seq 0 3)
  if [ $# -gt 1 ]; then
    peers_to_join=${@:2}
  fi
	for i in $peers_to_join; do
		#setEnvs $i
		channelJoinWithRetry ${channel} $i
		echo_g "=== peer$i joined into channel ${channel} === "
		sleep 1
	done
}

# Update the anchor peer at given channel
# updateAnchorPeers channel peer
updateAnchorPeers() {
	local channel=$1
  local peer=$2
  #setEnvs $peer
	echo_b "=== Update Anchor peers for org \"$CORE_PEER_LOCALMSPID\" on ${channel} === "
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel update \
		-o ${ORDERER_URL} \
		-c ${channel} \
		-f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx \
		>&log.txt
	else
		peer channel update \
		-o ${ORDERER_URL} \
		-c ${channel} \
		-f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx \
		--tls $CORE_PEER_TLS_ENABLED \
		--cafile ${ORDERER_TLS_CA} \
		>&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Anchor peer update failed"
	echo_g "=== Anchor peers for org \"$CORE_PEER_LOCALMSPID\" on ${channel} is updated. === "
	sleep 2
}

# Install chaincode on specified peer node
# chaincodeInstall peer cc_name version path
chaincodeInstall () {
	local peer=$1
	local name=$2
	local version=$3
	local path=$4
	echo_b "=== Install Chaincode $name:$version ($path) on peer$peer === "
	#setEnvs $peer
	peer chaincode install \
		-n ${name} \
		-v $version \
		-p ${path} \
		>&log.txt
	res=$?
	cat log.txt
  verifyResult $res "Chaincode installation on remote peer$peer has Failed"
	echo_g "=== Chaincode is installed on remote peer$peer === "
}

# Instantiate chaincode on specifized peer node
# chaincodeInstantiate channel peer name version args
chaincodeInstantiate () {
	local channel=$1
	local peer=$2
	local name=$3
	local version=$4
	local args=$5
	#setEnvs $peer
	echo_b "=== chaincodeInstantiate for channel ${channel} on peer $peer ===="
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
			--tls $CORE_PEER_TLS_ENABLED \
			--cafile ${ORDERER_TLS_CA} \
			>&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "ChaincodeInstantiation on peer$peer in channel ${channel} failed"
	echo_g "=== ChaincodeInstantiation on peer$peer in channel ${channel} is successful ==="
}


# channel peer name args
chaincodeInvoke () {
	local channel=$1
	local peer=$2
	local name=$3
	local args=$4
	echo_g "=== Invoke transaction on peer$peer in channel ${channel} === "
	#setEnvs $peer
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
			--tls $CORE_PEER_TLS_ENABLED \
			--cafile ${ORDERER_TLS_CA} \
			>&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Invoke execution on peer$peer failed "
	echo_g "=== Invoke transaction on peer$peer in channel ${channel} is successful === "
}

# query channel peer name args expected_result
chaincodeQuery () {
  local channel=$1
  local peer=$2
  local name=$3
  local args=$4
  [ $# -gt 4 ] && local expected_result=$5
  echo_b "=== Querying on peer$peer in channel ${channel}... === "
  local rc=1
  local starttime=$(date +%s)

  #setEnvs $peer
  # we either get a successful response, or reach TIMEOUT
  while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
  do
     echo_b "Attempting to Query peer$peer ...$(($(date +%s)-starttime)) secs"
     peer chaincode query \
			 -C "${channel}" \
			 -n "${name}" \
			 -c "${args}" \
			 >&log.txt
			if [ $# -gt 4 ]; then
			 test $? -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
			 test "$VALUE" = "${expected_result}" && let rc=0
			 sleep 3
			else
				rc=0
			fi
  done
  echo
  cat log.txt
  if test $rc -eq 0 ; then
	echo_g "=== Query on peer$peer in channel ${channel} is successful === "
  else
	echo_r "!!!!!!!!!!!!!!! Query result on peer$peer is INVALID !!!!!!!!!!!!!!!!"
  echo_r "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
	echo
	exit 1
  fi
}


# Start chaincode with dev mode
chaincodeStartDev () {
	local peer=$1
	local version=$2
	#setEnvs $peer
	#setEnvs 1 0
	setEnvs 1 0
	CORE_CHAINCODE_LOGLEVEL=debug \
	CORE_PEER_ADDRESS=peer${peer}.org1.example.com:7052 \
	CORE_CHAINCODE_ID_NAME=mycc:${version} \
	nohup ./scripts/chaincode_example02 > chaincode_dev.log &
	res=$?
	cat log.txt
	verifyResult $res "Chaincode start in dev mode has Failed"
	echo_g "=== Chaincode started in dev mode === "
	echo
}

# chaincodeUpgrade channel peer name version args
chaincodeUpgrade () {
	local channel=$1
	local peer=$2
	local name=$3
	local version=$4
	local args=$5
	echo_b "=== Upgrade chaincode to version $version on peer$peer in channel ${channel}  === "

	#setEnvs $peer
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
		--tls $CORE_PEER_TLS_ENABLED \
		--cafile ${ORDERER_TLS_CA} \
		>&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Upgrade execution on peer$peer failed "
	echo_g "=== Upgrade transaction on peer$peer in channel ${channel} is successful === "
	echo
}

# Fetch some block from a given channel: channel, peer, blockNum
channelFetch () {
	local channel=$1
	local peer=$2
	local num=$3
	echo_b "=== Fetch block $num on peer$peer in channel $channel === "

	#setEnvs $peer
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "${CORE_PEER_TLS_ENABLED}" -o "${CORE_PEER_TLS_ENABLED}" = "false" ]; then
		peer channel fetch $num ${channel}_block_${num}.block \
			-o ${ORDERER_URL} \
			-c ${channel}  \
			>&log.txt
	else
		peer channel fetch $num block_${num}.block \
			-o ${ORDERER_URL} \
			-c ${channel} \
			--tls \
			--cafile ${ORDERER_TLS_CA}  \
			>&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Fetch block on peer$peer failed"
	echo_g "=== Fetch block on peer$peer in channel $channel is successful === "
	echo
}