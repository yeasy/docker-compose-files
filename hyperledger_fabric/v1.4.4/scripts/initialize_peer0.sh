#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b " ========== Network initialization start ========== "

## Create channel
echo_b "Creating channel ${APP_CHANNEL} with ${APP_CHANNEL_TX}..."
channelCreate ${APP_CHANNEL} ${APP_CHANNEL_TX} ${ORDERER0_URL}

sleep 1

## Join all the peers to the channel
echo_b "Having peer0 join the channel..."
channelJoin ${APP_CHANNEL} 0

## Set the anchor peers for each org in the channel
echo_b "Updating anchor peers for peer0/org1... no use for only single channel"
channelUpdate ${APP_CHANNEL} 1 0 ${ORDERER0_URL}  ${ORDERER0_TLS_ROOTCERT} Org1MSPanchors.tx

## Install chaincode on all peers
CC_NAME=${CC_02_NAME}
CC_PATH=${CC_02_PATH}
echo_b "Installing chaincode ${CC_NAME} on peer0..."
chaincodeInstall 1 0 ${CC_NAME} ${CC_INIT_VERSION} ${CC_PATH}

# Instantiate chaincode on all peers
# Instantiate can only be executed once on any node
echo_b "Instantiating chaincode on the channel..."
chaincodeInstantiate ${APP_CHANNEL} 0

echo_g "=============== All GOOD, network initialization done =============== "
echo

exit 0
