#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "Channel name: "${CHANNEL_NAME}

#Query on chaincode on Peer0/Org1
echo_b "Querying chaincode on peer 3..."
setEnvs "Org2MSP" ${ORG2_PEER1_TLS_ROOTCERT} ${ORG2_ADMIN_MSP} ${ORG2_PEER1_URL}
chaincodeQuery ${CHANNEL_NAME} 3 ${CC_NAME} ${CC_QUERY_ARGS} 100

#Invoke on chaincode on Peer0/Org1
echo_b "Sending invoke transaction (transfer 10) on org1/peer0..."
setEnvs "Org1MSP" ${ORG1_PEER0_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER0_URL}
chaincodeInvoke ${CHANNEL_NAME} 0 ${CC_NAME} ${CC_INVOKE_ARGS}

#Query on chaincode on Peer1/Org2, check if the result is 90
echo_b "Querying chaincode on peer 1 and 3..."
setEnvs "Org1MSP" ${ORG1_PEER1_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER1_URL}
chaincodeQuery ${CHANNEL_NAME} 1 ${CC_NAME} ${CC_QUERY_ARGS} 90
setEnvs "Org2MSP" ${ORG2_PEER1_TLS_ROOTCERT} ${ORG2_ADMIN_MSP} ${ORG2_PEER1_URL}
chaincodeQuery ${CHANNEL_NAME} 3 ${CC_NAME} ${CC_QUERY_ARGS} 90

#Invoke on chaincode on Peer1/Org2
echo_b "Sending invoke transaction on org2/peer3..."
setEnvs "Org2MSP" ${ORG2_PEER1_TLS_ROOTCERT} ${ORG2_ADMIN_MSP} ${ORG2_PEER1_URL}
chaincodeInvoke ${CHANNEL_NAME} 3 ${CC_NAME} ${CC_INVOKE_ARGS}

#Query on chaincode on Peer1/Org2, check if the result is 80
echo_b "Querying chaincode on all 4peers..."
setEnvs "Org1MSP" ${ORG1_PEER0_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER0_URL}
chaincodeQuery ${CHANNEL_NAME} 0 ${CC_NAME} ${CC_QUERY_ARGS} 80
setEnvs "Org2MSP" ${ORG2_PEER0_TLS_ROOTCERT} ${ORG2_ADMIN_MSP} ${ORG2_PEER0_URL}
chaincodeQuery ${CHANNEL_NAME} 2 ${CC_NAME} ${CC_QUERY_ARGS} 80

#Upgrade to new version
echo_b "Upgrade chaincode to new version..."
setEnvs "Org1MSP" ${ORG1_PEER0_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER0_URL}
chaincodeInstall 0 ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_PATH}
setEnvs "Org1MSP" ${ORG1_PEER1_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER1_URL}
chaincodeInstall 1 ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_PATH}
setEnvs "Org2MSP" ${ORG2_PEER0_TLS_ROOTCERT} ${ORG2_ADMIN_MSP} ${ORG2_PEER0_URL}
chaincodeInstall 2 ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_PATH}
setEnvs "Org2MSP" ${ORG2_PEER1_TLS_ROOTCERT} ${ORG2_ADMIN_MSP} ${ORG2_PEER1_URL}
chaincodeInstall 3 ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_PATH}

# Upgrade on one peer of the channel will update all
setEnvs "Org1MSP" ${ORG1_PEER0_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER0_URL}
chaincodeUpgrade ${CHANNEL_NAME} 0 ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_UPGRADE_ARGS}

# Query new value, should refresh through all peers in the channel
setEnvs "Org1MSP" ${ORG1_PEER0_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER0_URL}
chaincodeQuery ${CHANNEL_NAME} 0 ${CC_NAME} ${CC_QUERY_ARGS} 100
setEnvs "Org2MSP" ${ORG2_PEER1_TLS_ROOTCERT} ${ORG2_ADMIN_MSP} ${ORG2_PEER1_URL}
chaincodeQuery ${CHANNEL_NAME} 3 ${CC_NAME} ${CC_QUERY_ARGS} 100

echo_g "=== All GOOD, chaincode test completed ==="
