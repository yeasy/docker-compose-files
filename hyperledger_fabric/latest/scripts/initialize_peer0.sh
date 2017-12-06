#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b " ========== Network initialization start ========== "

## Create channel
echo_b "Creating channel ${APP_CHANNEL}..."
channelCreate ${APP_CHANNEL}

sleep 1

## Join all the peers to the channel
echo_b "Having peer0 join the channel..."
channelJoin ${APP_CHANNEL} 0

## Set the anchor peers for each org in the channel
echo_b "Updating anchor peers for peer0/org1... no use for only single channel"
updateAnchorPeers ${APP_CHANNEL} 0

## Install chaincode on all peers
echo_b "Installing chaincode on peer0..."
chaincodeInstall 0 ${CC_INIT_ARGS}

# Instantiate chaincode on all peers
# Instantiate can only be executed once on any node
echo_b "Instantiating chaincode on the channel..."
chaincodeInstantiate ${APP_CHANNEL} 0

echo_g "=============== All GOOD, network initialization done =============== "
echo

exit 0
