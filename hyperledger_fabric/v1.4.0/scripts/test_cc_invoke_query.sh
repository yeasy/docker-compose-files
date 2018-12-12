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
echo_b "=== Testing Chaincode invoke/query ==="

# Non-side-DB testing
echo_b "Query chaincode ${CC_NAME} on peer org2/peer0..."
chaincodeQuery ${APP_CHANNEL} 2 1 ${CC_NAME} ${CC_QUERY_ARGS} 100

#Invoke on chaincode on Peer0/Org1
echo_b "Invoke transaction (transfer 10) by org1/peer0..."
chaincodeInvoke ${APP_CHANNEL} 1 0 ${CC_NAME} ${CC_INVOKE_ARGS}

#Query on chaincode on Peer1/Org2, check if the result is 90
echo_b "Query chaincode on org2/peer1..."
chaincodeQuery ${APP_CHANNEL} 2 1 ${CC_NAME} ${CC_QUERY_ARGS} 90

#Invoke on chaincode on Peer1/Org2
echo_b "Send invoke transaction on org2/peer1..."
chaincodeInvoke ${APP_CHANNEL} 2 1 ${CC_NAME} ${CC_INVOKE_ARGS}

#Query on chaincode on Peer1/Org2, check if the result is 80
echo_b "Query chaincode on org1/peer0 4peers..."
chaincodeQuery ${APP_CHANNEL} 1 0 ${CC_NAME} ${CC_QUERY_ARGS} 80

echo_g "=== Chaincode invoke/query done ==="
