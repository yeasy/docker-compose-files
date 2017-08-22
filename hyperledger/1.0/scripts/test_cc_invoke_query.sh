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

echo
echo "  ______    __     __      _       _____    ____     _    ______      ______      ______      _____ "
echo " / _____|  |  |   |  |    / \     |_   _|  | |\ \   | |   / _____|   / ______ \   |  ___\ \   | ____|"
echo "/ /        |  |---|  |   / _ \      | |    | | \ \  | |  / /        / /      \ \  | |    \ \  |  _|  "
echo "\ \_____   |  |---|  |  / ___ \    _| |_   | |  \ \ | |  \ \_____   \ \______/ /  | |____/ /  | |___ "
echo " \______|  |__|   |__| /_/   \_\  |_____|  |_|   \_\|_|   \______|   \ ______ /   |_______/   |_____|"
echo


CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="businesschannel"}
: ${TIMEOUT:="60"}
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

echo_b "Channel name : "$CHANNEL_NAME

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

chaincodeQuery () {
  PEER=$1
  echo_b "===================== Querying on PEER$PEER on channel '$CHANNEL_NAME'... ===================== "
  setGlobals $PEER
  local rc=1
  local starttime=$(date +%s)

  # continue to poll
  # we either get a successful response, or reach TIMEOUT
  while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
  do
     sleep 3
     echo_b "Attempting to Query PEER$PEER ...$(($(date +%s)-starttime)) secs"
     peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}' >&log.txt
     test $? -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
     test "$VALUE" = "$2" && let rc=0
  done
  echo
  cat log.txt
  if test $rc -eq 0 ; then
	echo_g "===================== Query on PEER$PEER on channel '$CHANNEL_NAME' is successful ===================== "
  else
	echo_r "!!!!!!!!!!!!!!! Query result on PEER$PEER is INVALID !!!!!!!!!!!!!!!!"
        echo_r "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
	echo
	exit 1
  fi
}

chaincodeInvoke () {
	PEER=$1
	setGlobals $PEER
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}' >&log.txt
	else
		peer chaincode invoke -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}' >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Invoke execution on PEER$PEER failed "
	echo_g "===================== Invoke transaction on PEER$PEER on channel '$CHANNEL_NAME' is successful ===================== "
	echo
}


#Query on chaincode on Peer0/Org1
echo_b "Querying chaincode on all 4 peers..."
chaincodeQuery 0 100
chaincodeQuery 1 100
chaincodeQuery 2 100
chaincodeQuery 3 100

#Invoke on chaincode on Peer0/Org1
echo_b "Sending invoke transaction (transfer 10) on org1/peer0..."
chaincodeInvoke 0

#Query on chaincode on Peer1/Org2, check if the result is 90
echo_b "Querying chaincode on all 4 peers..."
chaincodeQuery 0 90
chaincodeQuery 1 90
chaincodeQuery 2 90
chaincodeQuery 3 90

#Invoke on chaincode on Peer1/Org2
echo_b "Sending invoke transaction on org2/peer3..."
chaincodeInvoke 3

#Query on chaincode on Peer1/Org2, check if the result is 80
echo_b "Querying chaincode on all 4peers..."
chaincodeQuery 0 80
chaincodeQuery 1 80
chaincodeQuery 2 80
chaincodeQuery 3 80

echo
echo_g "===================== All GOOD, End-2-End execution completed ===================== "
echo

echo
echo " _____   _   _   ____  "
echo "| ____| | \ | | |  _ \ "
echo "|  _|   |  \| | | | | |"
echo "| |___  | |\  | | |_| |"
echo "|_____| |_| \_| |____/ "
echo

exit 0
