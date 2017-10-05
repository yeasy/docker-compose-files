#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "Channel name : "$CHANNEL_NAME

#Query on chaincode on Peer0/Org1
echo_b "Querying chaincode on peer 3..."
chaincodeQuery 3 100

#Invoke on chaincode on Peer0/Org1
echo_b "Sending invoke transaction (transfer 10) on org1/peer0..."
chaincodeInvoke 0

#Query on chaincode on Peer1/Org2, check if the result is 90
echo_b "Querying chaincode on peer 1 and 3..."
chaincodeQuery 1 90
chaincodeQuery 3 90

#Invoke on chaincode on Peer1/Org2
echo_b "Sending invoke transaction on org2/peer3..."
chaincodeInvoke 3

#Query on chaincode on Peer1/Org2, check if the result is 80
echo_b "Querying chaincode on all 4peers..."
chaincodeQuery 0 80
chaincodeQuery 2 80

#Upgrade to new version
chaincodeInstall 0 1.1
chaincodeInstall 1 1.1
chaincodeInstall 2 1.1
chaincodeInstall 3 1.1

chaincodeUpgrade 0 1.1

chaincodeQuery 0 100
chaincodeQuery 3 100

echo
echo_g "===================== All GOOD, End-2-End execution completed ===================== "
echo

exit 0
