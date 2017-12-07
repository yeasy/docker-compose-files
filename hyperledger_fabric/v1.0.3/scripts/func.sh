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

CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="businesschannel"}

CC_NAME=mycc

: ${TIMEOUT:="60"}
COUNTER=1
MAX_RETRY=5

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo_b "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
		echo_r "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
		echo
   		exit 1
	fi
}

setGlobals () {
	if [ $1 -eq 0 -o $1 -eq 1 ] ; then
		CORE_PEER_LOCALMSPID="Org1MSP"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
		if [ $1 -eq 0 ]; then
			CORE_PEER_ADDRESS=peer0.org1.example.com:7051
		else
			CORE_PEER_ADDRESS=peer1.org1.example.com:7051
		fi
	else
		CORE_PEER_LOCALMSPID="Org2MSP"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
		if [ $1 -eq 2 ]; then
			CORE_PEER_ADDRESS=peer0.org2.example.com:7051
		else
			CORE_PEER_ADDRESS=peer1.org2.example.com:7051
		fi
	fi

	env |grep CORE
}

checkOSNAvailability() {
	#Use orderer's MSP for fetching system channel config block
	CORE_PEER_LOCALMSPID="OrdererMSP"
	CORE_PEER_TLS_ROOTCERT_FILE=$ORDERER_CA
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp

	local rc=1
	local starttime=$(date +%s)

	# continue to poll
	# we either get a successful response, or reach TIMEOUT
	while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
	do
		 sleep 3
		 echo "Attempting to fetch system channel 'testchainid' ...$(($(date +%s)-starttime)) secs"
		 if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
			 peer channel fetch 0 -o orderer.example.com:7050 -c "testchainid" >&log.txt
		 else
			 peer channel fetch 0 -o orderer.example.com:7050 -c "testchainid" --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		 fi
		 test $? -eq 0 && VALUE=$(cat log.txt | awk '/Received block/ {print $NF}')
		 test "$VALUE" = "0" && let rc=0
	done
	cat log.txt
	verifyResult $rc "Ordering Service is not available, Please try again ..."
	echo "===================== Ordering Service is up and running ===================== "
	echo
}

# Use peer0/org1 to create a channel
channelCreate() {
	CHANNEL_NAME=$1
	echo_b "===================== Create Channel \"$CHANNEL_NAME\" ===================== "
	setGlobals 0
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel create \
			-o orderer.example.com:7050 \
			-c $CHANNEL_NAME \
			-f ./channel-artifacts/channel.tx \
			--timeout $TIMEOUT \
			>&log.txt
	else
		peer channel create \
			-o orderer.example.com:7050 \
			-c $CHANNEL_NAME \
			-f ./channel-artifacts/channel.tx \
			--tls $CORE_PEER_TLS_ENABLED \
			--cafile $ORDERER_CA \
			--timeout $TIMEOUT \
			>&log.txt
	fi
	res=$?
	cat log.txt
	if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
		COUNTER=` expr $COUNTER + 1`
		echo_b "Fail to create channel $CHANNEL_NAME, Retry after 3 seconds"
		sleep 3
		channelCreate $CHANNEL_NAME
	else
		COUNTER=1
	fi
	verifyResult $res "Channel creation failed"
	echo_g "===================== Channel \"$CHANNEL_NAME\" is created successfully ===================== "
	echo
}

updateAnchorPeers() {
	CHANNEL_NAME=$1
  PEER=$2
  setGlobals $PEER
	echo_b "===================== Update Anchor peers for org \"$CORE_PEER_LOCALMSPID\" on \"$CHANNEL_NAME\" ===================== "
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx >&log.txt
	else
		peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Anchor peer update failed"
	echo_g "===================== Anchor peers for org \"$CORE_PEER_LOCALMSPID\" on \"$CHANNEL_NAME\" is updated successfully ===================== "
	sleep 5
	echo
}

## Sometimes Join takes time hence RETRY atleast for 5 times
joinWithRetry () {
	peer channel join -b $CHANNEL_NAME.block  >&log.txt
	res=$?
	cat log.txt
	if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
		COUNTER=` expr $COUNTER + 1`
		echo_b "PEER$1 failed to join the channel, Retry after 2 seconds"
		sleep 2
		joinWithRetry $1
	else
		COUNTER=1
	fi
        verifyResult $res "After $MAX_RETRY attempts, PEER$ch has failed to Join the Channel"
}

# Join given (by default all) peers into the channel
channelJoin () {
	CHANNEL_NAME=$1
	echo_b "===================== Join peers into the channel \"$CHANNEL_NAME\" ===================== "
	peers_to_join=$(seq 0 3)
  if [ $# -gt 1 ]; then
    peers_to_join=${@:2}
  fi
	for i in $peers_to_join; do
		setGlobals $i
		joinWithRetry $i
		echo_g "===================== PEER$i joined into the channel \"$CHANNEL_NAME\" ===================== "
		sleep 2
		echo
	done
}

# Instantiate chaincode on specifized peer node
chaincodeInstantiate () {
	CHANNEL_NAME=$1
	PEER=$2
	setGlobals $PEER
	echo_b "===================== chaincodeInstantiate for channel $CHANNEL_NAME on peer $PEER ============"
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode instantiate \
			-o orderer.example.com:7050 \
			-C $CHANNEL_NAME \
			-n $CC_NAME \
			-v 1.0 \
			-c '{"Args":["init","a","100","b","200"]}' \
			-P "OR	('Org1MSP.member','Org2MSP.member')" \
			>&log.txt
	else
		peer chaincode instantiate \
			-o orderer.example.com:7050 \
			-C $CHANNEL_NAME \
			-n $CC_NAME \
			-v 1.0 \
			-c '{"Args":["init","a","100","b","200"]}' \
			-P "OR	('Org1MSP.member','Org2MSP.member')" \
			--tls $CORE_PEER_TLS_ENABLED \
			--cafile $ORDERER_CA \
			>&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Chaincode instantiation on PEER$PEER in channel '$CHANNEL_NAME' failed"
	echo_g "===================== Chaincode Instantiation on PEER$PEER in channel '$CHANNEL_NAME' is successful ===================== "
	echo
}

chaincodeQuery () {
  PEER=$1
  echo_b "===================== Querying on PEER$PEER in channel '$CHANNEL_NAME'... ===================== "
  setGlobals $PEER
  local rc=1
  local starttime=$(date +%s)

  # continue to poll
  # we either get a successful response, or reach TIMEOUT
  while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
  do
     sleep 3
     echo_b "Attempting to Query PEER$PEER ...$(($(date +%s)-starttime)) secs"
     peer chaincode query -C $CHANNEL_NAME -n $CC_NAME -c '{"Args":["query","a"]}' >&log.txt
     test $? -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
     test "$VALUE" = "$2" && let rc=0
  done
  echo
  cat log.txt
  if test $rc -eq 0 ; then
	echo_g "===================== Query on PEER$PEER in channel '$CHANNEL_NAME' is successful ===================== "
  else
	echo_r "!!!!!!!!!!!!!!! Query result on PEER$PEER is INVALID !!!!!!!!!!!!!!!!"
        echo_r "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
	echo
	exit 1
  fi
}

chaincodeInvoke () {
	PEER=$1
	echo_g "===================== Invoke transaction on PEER$PEER in channel '$CHANNEL_NAME'===================== "
	setGlobals $PEER
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME -n $CC_NAME -c '{"Args":["invoke","a","b","10"]}' >&log.txt
	else
		peer chaincode invoke -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{"Args":["invoke","a","b","10"]}' >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Invoke execution on PEER$PEER failed "
	echo_g "===================== Invoke transaction on PEER$PEER in channel '$CHANNEL_NAME' is successful ===================== "
	echo
}

# Install chaincode on specifized peer node
chaincodeInstall () {
	PEER=$1
	echo_b "===================== Install Chaincode on remote peer PEER$PEER ===================== "
	VERSION=$2
	setGlobals $PEER
	peer chaincode install -n $CC_NAME -v $VERSION -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 >&log.txt
	res=$?
	cat log.txt
        verifyResult $res "Chaincode installation on remote peer PEER$PEER has Failed"
	echo_g "===================== Chaincode is installed on remote peer PEER$PEER ===================== "
	echo
}

# Start chaincode with dev mode
chaincodeStartDev () {
	PEER=$1
	VERSION=$2
	setGlobals $PEER
	CORE_CHAINCODE_LOGLEVEL=debug \
	CORE_PEER_ADDRESS=peer${PEER}.org1.example.com:7052 \
	CORE_CHAINCODE_ID_NAME=mycc:${VERSION} \
	nohup ./scripts/chaincode_example02 > chaincode_dev.log &
	res=$?
	cat log.txt
	verifyResult $res "Chaincode start in dev mode has Failed"
	echo_g "===================== Chaincode started in dev mode ===================== "
	echo
}

# chaincodeUpgrade 0 1.1
chaincodeUpgrade () {
	CHANNEL_NAME=$1
	PEER=$2
	VERSION=$3
	echo_b "===================== Upgrade chaincode to version $VERSION on PEER$PEER in channel '$CHANNEL_NAME'  ===================== "
	setGlobals $PEER
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode upgrade -o orderer.example.com:7050 -C $CHANNEL_NAME -n $CC_NAME -c '{"Args":["upgrade","a","100","b","200"]}' -v $VERSION >&log.txt
	else
		peer chaincode upgrade -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{"Args":["upgrade","a","100","b","200"]}' -v $VERSION >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Upgrade execution on PEER$PEER failed "
	echo_g "===================== Upgrade transaction on PEER$PEER in channel '$CHANNEL_NAME' is successful ===================== "
	echo
}

channelFetch () {
	PEER=$1
	BLOCK_NO=$2
	echo_b "===================== Fetch block $BLOCK_NO on PEER$PEER in channel '$CHANNEL_NAME' ===================== "
	setGlobals $PEER
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "${CORE_PEER_TLS_ENABLED}" -o "${CORE_PEER_TLS_ENABLED}" = "false" ]; then
		peer channel fetch $BLOCK_NO \
			-o orderer.example.com:7050 \
			-c ${CHANNEL_NAME}  >&log.txt
	else
		peer channel fetch $BLOCK_NO block_${BLOCK_NO}.block \
			-o orderer.example.com:7050 \
			-c $CHANNEL_NAME \
			--tls \
			--cafile $ORDERER_CA  >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Fetch block on PEER$PEER failed "
	echo_g "===================== Fetch block on PEER$PEER in channel '$CHANNEL_NAME' is successful ===================== "
	echo
}