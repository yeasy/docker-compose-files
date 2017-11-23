#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

#set -x

## Create channel
echo_b "Creating channel ${CHANNEL_NAME}..."
setEnvs "Org1MSP" ${ORG1_PEER0_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER0_URL}
channelCreate ${CHANNEL_NAME}

## Join all the peers to the channel
echo_b "Having all peers join the channel ${CHANNEL_NAME}..."
setEnvs "Org1MSP" ${ORG1_PEER0_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER0_URL}
channelJoin ${CHANNEL_NAME} 0
setEnvs "Org1MSP" ${ORG1_PEER1_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER1_URL}
channelJoin ${CHANNEL_NAME} 1
setEnvs "Org2MSP" ${ORG2_PEER0_TLS_ROOTCERT} ${ORG2_ADMIN_MSP} ${ORG2_PEER0_URL}
channelJoin ${CHANNEL_NAME} 2
setEnvs "Org2MSP" ${ORG2_PEER1_TLS_ROOTCERT} ${ORG2_ADMIN_MSP} ${ORG2_PEER1_URL}
channelJoin ${CHANNEL_NAME} 3