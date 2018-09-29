#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

CC_NAME=${CC_NAME:-$CC_02_NAME}
CC_INVOKE_ARGS=${CC_INVOKE_ARGS:-$CC_02_INVOKE_ARGS}
CC_QUERY_ARGS=${CC_QUERY_ARGS:-$CC_02_QUERY_ARGS}

#Query on chaincode on Peer0/Org1
echo_g "=== Testing Chaincode invoke/query ==="

echo_b "Querying chaincode ${CC_NAME} on peer org2/peer0..."
chaincodeQuery ${APP_CHANNEL} 2 1 ${CC_NAME} ${CC_QUERY_ARGS} 100

#Invoke on chaincode on Peer0/Org1
echo_b "Sending invoke transaction (transfer 10) representing org1/peer0..."
chaincodeInvoke ${APP_CHANNEL} 1 0 ${CC_NAME} ${CC_INVOKE_ARGS}

#Query on chaincode on Peer1/Org2, check if the result is 90
echo_b "Querying chaincode on peer 1 and 3..."
chaincodeQuery ${APP_CHANNEL} 1 1 ${CC_NAME} ${CC_QUERY_ARGS} 90
chaincodeQuery ${APP_CHANNEL} 2 1 ${CC_NAME} ${CC_QUERY_ARGS} 90

#Invoke on chaincode on Peer1/Org2
echo_b "Sending invoke transaction on org2/peer3..."
chaincodeInvoke ${APP_CHANNEL} 2 1 ${CC_NAME} ${CC_INVOKE_ARGS}

#Query on chaincode on Peer1/Org2, check if the result is 80
echo_b "Querying chaincode on all 4peers..."
chaincodeQuery ${APP_CHANNEL} 1 0 ${CC_NAME} ${CC_QUERY_ARGS} 80
chaincodeQuery ${APP_CHANNEL} 2 0 ${CC_NAME} ${CC_QUERY_ARGS} 80

echo_g "=== Chaincode invoke/query completed ==="

echo
