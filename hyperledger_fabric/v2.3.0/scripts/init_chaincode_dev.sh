#!/usr/bin/env bash

# This script will build and start and test chaincode in DEV mode

if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
else
	echo "Cannot find the func.sh files, pls check"
	exit 1
fi

echo
echo " ============================================== "
echo " ==========initialize businesschannel========== "
echo " ============================================== "
echo

echo_b "Channel name: "${APP_CHANNEL}

## Create channel
echo_b "Creating channel..."
channelCreate ${APP_CHANNEL} ${APP_CHANNEL_TX} ${ORDERER0_URL}

sleep 1

## Join all the peers to the channel
echo_b "Having peer0 join the channel..."
channelJoin ${APP_CHANNEL} 0

sleep 1

## Set the anchor peers for each org in the channel
#echo_b "Updating anchor peers for peer0/org1... no use for only single channel"
#updateAnchorPeers 0

# We suppose the binary is there, otherwise, run `go build` under the chaincode path
chaincodeStartDev 0 1.0
sleep 1

## Install chaincode on all peers
echo_b "Installing chaincode on peer0..."
chaincodeInstall 0 1.0

sleep 1

# Instantiate chaincode on all peers
# Instantiate can only be executed once on any node
echo_b "Instantiating chaincode on the channel..."
chaincodeInstantiate 0

sleep 1

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
