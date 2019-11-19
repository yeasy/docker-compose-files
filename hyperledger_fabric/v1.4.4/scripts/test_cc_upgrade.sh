#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

CC_NAME=${CC_NAME:-$CC_02_NAME}
CC_PATH=${CC_PATH:-$CC_02_PATH}
CC_UPGRADE_ARGS=${CC_UPGRADE_ARGS:-$CC_02_UPGRADE_ARGS}
CC_QUERY_ARGS=${CC_QUERY_ARGS:-$CC_02_QUERY_ARGS}

#Upgrade to new version
echo_b "=== Upgrade chaincode ${CC_NAME} to new version... ==="

chaincodeInstall 1 0 "${CC_NAME}" "${CC_UPGRADE_VERSION}" "${CC_PATH}"
chaincodeInstall 1 1 "${CC_NAME}" "${CC_UPGRADE_VERSION}" "${CC_PATH}"
chaincodeInstall 2 0 "${CC_NAME}" "${CC_UPGRADE_VERSION}" "${CC_PATH}"
chaincodeInstall 2 1 "${CC_NAME}" "${CC_UPGRADE_VERSION}" "${CC_PATH}"

# Upgrade on one peer of the channel will update all
chaincodeUpgrade ${APP_CHANNEL} 1 0 ${ORDERER0_URL} "${CC_NAME}" "${CC_UPGRADE_VERSION}" "${CC_UPGRADE_ARGS}"

# Query new value, should refresh through all peers in the channel
chaincodeQuery 1 0 "${ORG1_PEER0_URL}" "${ORG1_PEER0_TLS_ROOTCERT}" ${APP_CHANNEL} "${CC_NAME}" "${CC_QUERY_ARGS}" 100
chaincodeQuery 2 1 "${ORG1_PEER0_URL}" "${ORG1_PEER0_TLS_ROOTCERT}" ${APP_CHANNEL} "${CC_NAME}" "${CC_QUERY_ARGS}" 100

echo_g "=== chaincode ${CC_NAME} Upgrade completed ==="

echo
