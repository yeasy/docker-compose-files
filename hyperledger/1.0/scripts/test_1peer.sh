#!/bin/bash

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
: ${TIMEOUT:="60"}
COUNTER=0
MAX_RETRY=5
CC_PATH=github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02

echo_b "Channel name : "$CHANNEL_NAME

verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo_b "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
                echo_r "================== ERROR !!! FAILED to execute MVE =================="
		echo
   		exit 1
	fi
}

createChannel() {
	peer channel create -o orderer.example.com:7050 -c ${CHANNEL_NAME} -f ./channel-artifacts/channel.tx >&log.txt
	res=$?
	cat log.txt

	verifyResult $res "Channel creation failed"
	echo

	# verify file newchannel.block exist
	if [ -s mychannel.block ]; then
		res=$?
		verifyResult $res "Channel created failed"
	fi
		echo_g "================channel \"$CHANNEL_NAME\" is created successfully ==============="
}

## Sometimes Join takes time hence RETRY atleast for 5 times

joinChannel () {
    echo_b "===================== PEER0 joined on the channel \"$CHANNEL_NAME\" ===================== "
	peer channel join -b ${CHANNEL_NAME}.block -o orderer.example.com:7050 >&log.txt
	res=$?
	cat log.txt
	if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
		COUNTER=` expr $COUNTER + 1`
		echo_r "PEER0 failed to join the channel, Retry after 2 seconds"
		sleep 2
		joinWithRetry
	else
		COUNTER=0
	fi
        verifyResult $res "After $MAX_RETRY attempts, PEER0 has failed to Join the Channel"
}

updateAnchorPeers() {
    peer channel create -o orderer.example.com:7050 -c ${CHANNEL_NAME} -f ./channel-artifacts/Org1MSPanchors.tx >&log.txt
    res=$?
    cat log.txt
    verifyResult $res "Anchor peer update failed"
    echo_g "==== Anchor peers for org1 on mychannel is updated successfully======"
    echo
}

installChaincode () {
	peer chaincode install -n mycc -v 1.0 -p ${CC_PATH} -o orderer.example.com:7050 >&log.txt
	res=$?
	cat log.txt
        verifyResult $res "Chaincode installation on remote peer0 has Failed"
	echo_g "===================== Chaincode is installed success on remote peer0===================== "
	echo
}

instantiateChaincode () {
	local starttime=$(date +%s)
	peer chaincode instantiate -o orderer.example.com:7050 -C ${CHANNEL_NAME} -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR ('Org1MSP.member')" >&log.txt
	res=$?
	cat log.txt
	verifyResult $res "Chaincode instantiation on pee0.org1 on channel '$CHANNEL_NAME' failed"
	echo_g "=========== Chaincode Instantiation on peer0.org1 on channel '$CHANNEL_NAME' is successful ========== "
	echo_b "Instantiate spent $(($(date +%s)-starttime)) secs"
	echo
}

chaincodeQuery () {
  local rc=1
  local starttime=$(date +%s)

  while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
  do
     sleep 3
     echo_b "Attempting to Query peer0.org1 ...$(($(date +%s)-starttime)) secs"
     peer chaincode query -C ${CHANNEL_NAME} -n mycc -c '{"Args":["query","a"]}' >&log.txt
     test $? -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
     test "$VALUE" = "$1" && let rc=0
  done
  echo
  cat log.txt
  if test $rc -eq 0 ; then
	echo_g "===================== Query on peer0.org1 on channel '$CHANNEL_NAME' is successful ===================== "

  else
	echo_r "!!!!!!!!!!!!!!! Query result on peer0.org1 is INVALID !!!!!!!!!!!!!!!!"
        echo_r "================== ERROR !!! FAILED to execute MVE test =================="
	echo
  fi
}

chaincodeInvoke () {
	peer chaincode invoke -o orderer.example.com:7050 -C ${CHANNEL_NAME} -n mycc -c '{"Args":["invoke","a","b","10"]}' >&log.txt
	res=$?
	cat log.txt
	verifyResult $res "Invoke execution on peer0.org1 failed "
	echo_g "========= Invoke transaction on peer0.org1 on channel '$CHANNEL_NAME' is successful ===== "
	echo
}

echo_b "====================1.Create channel(default newchannel) ============================="
createChannel

echo_b "====================2.Join pee0 to the channel ======================================"
joinChannel

echo_b "====================3.set anchor peers for org1 in the channel==========================="
updateAnchorPeers

echo_b "=====================4.Install chaincode test_cc on Peer0/Org0========================"
installChaincode

echo_b "=====================5.Instantiate chaincode, this will take a while, pls waiting...==="
instantiateChaincode

echo_b "====================6.Query the existing value of a===================================="
chaincodeQuery  100

echo_b "=====================7.Invoke a transaction to transfer 10 from a to b=================="
chaincodeInvoke

echo_b "=====================8.Check if the result of a is 90==================================="
chaincodeQuery  90

echo
echo_g "=====================9.All GOOD, MVE Test completed ===================== "
echo
exit 0
