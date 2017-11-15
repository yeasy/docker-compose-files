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
chaincodeQuery ${CHANNEL_NAME} 3 ${CC_NAME} ${CC_QUERY_ARGS} 100

#Invoke on chaincode on Peer0/Org1
echo_b "Sending invoke transaction (transfer 10) on org1/peer0..."
chaincodeInvoke ${CHANNEL_NAME} 0 ${CC_NAME} ${CC_INVOKE_ARGS}

#Query on chaincode on Peer1/Org2, check if the result is 90
echo_b "Querying chaincode on peer 1 and 3..."
chaincodeQuery ${CHANNEL_NAME} 1 ${CC_NAME} ${CC_QUERY_ARGS} 90
chaincodeQuery ${CHANNEL_NAME} 3 ${CC_NAME} ${CC_QUERY_ARGS} 90

#Invoke on chaincode on Peer1/Org2
echo_b "Sending invoke transaction on org2/peer3..."
chaincodeInvoke ${CHANNEL_NAME} 3 ${CC_NAME} ${CC_INVOKE_ARGS}

#Query on chaincode on Peer1/Org2, check if the result is 80
echo_b "Querying chaincode on all 4peers..."
chaincodeQuery ${CHANNEL_NAME} 0 ${CC_NAME} ${CC_QUERY_ARGS} 80
chaincodeQuery ${CHANNEL_NAME} 2 ${CC_NAME} ${CC_QUERY_ARGS} 80

#Upgrade to new version
chaincodeInstall 0 ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_PATH}
chaincodeInstall 1 ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_PATH}
chaincodeInstall 2 ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_PATH}
chaincodeInstall 3 ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_PATH}
chaincodeUpgrade ${CHANNEL_NAME} 0 ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_UPGRADE_ARGS}

# Query new value, should refresh through all peers in the channel
chaincodeQuery ${CHANNEL_NAME} 0 ${CC_NAME} ${CC_QUERY_ARGS} 100
chaincodeQuery ${CHANNEL_NAME} 3 ${CC_NAME} ${CC_QUERY_ARGS} 100

echo_g "=== All GOOD, End-2-End execution completed ==="

exit 0
