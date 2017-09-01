#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo
echo " ============================================== "
echo " ==========initialize businesschannel========== "
echo " ============================================== "
echo

echo_b "Channel name : "$CHANNEL_NAME

## Create channel
echo_b "Creating channel..."
createChannel

## Join all the peers to the channel
echo_b "Having all peers join the channel..."
joinChannel 0

## Set the anchor peers for each org in the channel
echo_b "Updating anchor peers for peer0/org1..."
updateAnchorPeers 0

## Install chaincode on all peers
echo_b "Installing chaincode on peer0..."
installChaincode 0

# Instantiate chaincode on all peers
# Instantiate can only be executed once on any node
echo_b "Instantiating chaincode on the channel..."
instantiateChaincode 0

echo
echo_g "===================== All GOOD, initialization completed ===================== "
echo

echo
echo " _____   _   _   ____  "
echo "| ____| | \ | | |  _ \ "
echo "|  _|   |  \| | | | | |"
echo "| |___  | |\  | | |_| |"
echo "|_____| |_| \_| |____/ "
echo

exit 0
