#!/bin/bash

CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="newchannel"}
: ${TIMEOUT:="60"}
COUNTER=0
MAX_RETRY=5
CC_PATH=github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02

echo "Channel name : "$CHANNEL_NAME

verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
                echo "================== ERROR !!! FAILED to execute MVE =================="
		echo
   		exit 1
	fi
}

setGlobals () {

	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer/peer0/localMspConfig
	CORE_PEER_ADDRESS=peer0:7051
	CORE_PEER_LOCALMSPID="Org0MSP"
	#env |grep CORE
}

createChannel() {
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/orderer/localMspConfig
	CORE_PEER_LOCALMSPID="OrdererMSP"
	env|grep CORE_PEER_MSPCONFIGPATH
	env|grep CORE_PEER_LOCALMSPID

	peer channel create -c ${CHANNEL_NAME} -o orderer0:7050 -f peer/crypto/orderer/channel.tx >&log.txt
	res=$?
	cat log.txt

	verifyResult $res "Channel creation failed"
	echo

	# verify file newchannel.block exist
	if [ -s newchannel.block ]; then
		res=$?
		verifyResult $res "Channel created failed"
	fi
		echo "================channel \"$CHANNEL_NAME\" is created successfully ==============="
}

## Sometimes Join takes time hence RETRY atleast for 5 times

joinChannel () {
    echo "===================== PEER0 joined on the channel \"$CHANNEL_NAME\" ===================== "
	setGlobals
	env|grep CORE_PEER_MSPCONFIGPATH
	env|grep CORE_PEER_LOCALMSPID
	env|grep CORE_PEER_ADDRESS
	peer channel join -b ${CHANNEL_NAME}.block -o orderer0:7050 >&log.txt
	res=$?
	cat log.txt
	if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
		COUNTER=` expr $COUNTER + 1`
		echo "PEER0 failed to join the channel, Retry after 2 seconds"
		sleep 2
		joinWithRetry
	else
		COUNTER=0
	fi
        verifyResult $res "After $MAX_RETRY attempts, PEER0 has failed to Join the Channel"
}

installChaincode () {
	setGlobals
	peer chaincode install -n test_cc -p ${CC_PATH}  -v 1.0 -o orderer0:7050 >&log.txt
	res=$?
	cat log.txt
        verifyResult $res "Chaincode installation on remote peer0 has Failed"
	echo "===================== Chaincode is installed success on remote peer0===================== "
	echo
}

instantiateChaincode () {
	setGlobals
	local starttime=$(date +%s)
	peer chaincode instantiate -o orderer0:7050 -C ${CHANNEL_NAME} -n test_cc -v 1.0 -p ${CC_PATH} -c '{"Args":["init","a","100","b","200"]}' -P "OR	('Org0MSP.member','Org1MSP.member')" >&log.txt
	res=$?
	cat log.txt
	verifyResult $res "Chaincode instantiation on PEER0 on channel '$CHANNEL_NAME' failed"
	echo "=========== Chaincode Instantiation on PEER0 on channel '$CHANNEL_NAME' is successful ========== "
	echo "Instantiate spent $(($(date +%s)-starttime)) secs"
	echo
}

chaincodeQuery () {
  setGlobals
  local rc=1
  local starttime=$(date +%s)

  while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
  do
     sleep 3
     echo "Attempting to Query PEER0 ...$(($(date +%s)-starttime)) secs"
     peer chaincode query -C ${CHANNEL_NAME} -n test_cc -c '{"Args":["query","a"]}' >&log.txt
     test $? -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
     test "$VALUE" = "$1" && let rc=0
  done
  echo
  cat log.txt
  if test $rc -eq 0 ; then
	echo "===================== Query on PEER0 on channel '$CHANNEL_NAME' is successful ===================== "

  else
	echo "!!!!!!!!!!!!!!! Query result on PEER0 is INVALID !!!!!!!!!!!!!!!!"
        echo "================== ERROR !!! FAILED to execute MVE test =================="
	echo
  fi
}

chaincodeInvoke () {
	setGlobals
	peer chaincode invoke -o orderer0:7050 -C ${CHANNEL_NAME} -n test_cc -c '{"Args":["invoke","a","b","10"]}' >&log.txt
	res=$?
	cat log.txt
	verifyResult $res "Invoke execution on PEER0 failed "
	echo "========= Invoke transaction on PEER0 on channel '$CHANNEL_NAME' is successful ===== "
	echo
}

echo "====================1.Create channel(default newchannel) ============================="
createChannel

echo "====================2.Join pee0 to the channel ======================================"
joinChannel

echo "=====================3.Install chaincode test_cc on Peer0/Org0========================"
installChaincode

echo "=====================4.Instantiate chaincode, this will take a while, pls waiting...==="
instantiateChaincode

echo "====================5.Query the existing value of a===================================="
chaincodeQuery  100

#Query b on chaincode
#chaincodeQuery b 200

echo "=====================6.Invoke a transaction to transfer 10 from a to b=================="
chaincodeInvoke

echo "=====================7.Check if the result of a is 90==================================="
chaincodeQuery  90

echo
echo "=====================8.All GOOD, MVE Test completed ===================== "
echo
exit 0
