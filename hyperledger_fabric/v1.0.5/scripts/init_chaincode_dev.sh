#!/usr/bin/env bash

# This script will build and start and test chaincode in DEV mode

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

echo_b "Channel name: "${APP_CHANNEL}

## Create channel
echo_b "Creating channel..."
channelCreate

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


echo "Starting chaincode in dev mode..."
cd $GOPATH/src/github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02
go build
CORE_CHAINCODE_LOGLEVEL=debug \
CORE_PEER_ADDRESS=peer0.org1.example.com:7052 \
CORE_CHAINCODE_ID_NAME=mycc:1.0 \
./chaincode_example02 &

echo "Install chaincode"
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
peer chaincode install \
-n mycc \
-v 1.0 \
-p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02

echo "Instantiate chaincode"
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
peer chaincode instantiate \
-n mycc \
-v 1.0 \
-c '{"Args":["init","a","100","b","200"]}' \
-o orderer.example.com:7050 \
-C businesschannel

echo "Invoke chaincode..."
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
peer chaincode invoke \
-n mycc \
-c '{"Args":["invoke","a","b","10"]}' \
-o orderer.example.com:7050 \
-C businesschannel

echo "Query chaincode..."
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
peer chaincode query \
-n mycc \
-c '{"Args":["query","a"]}' \
-o orderer.example.com:7050 \
-C businesschannel
