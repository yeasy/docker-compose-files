#! /bin/bash

echo "replace configtx.yaml and crypto-config.yaml"
cp ./peer/example2/configtx.yaml ./peer
cp ./peer/example2/crypto-config.yaml ./peer

echo "replace auto-test script "
cp ./peer/example2/new-channel-auto-test-5-peers.sh ./peer/scripts

echo "replace configtx.yaml"
cp ./peer/configtx.yaml /etc/hyperledger/fabric

echo "Generate new certificates"

cryptogen generate --config=./peer/crypto-config.yaml --output ./peer/crypto

echo "Generate new certificates"
configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./peer/channel-artifacts/orderer_genesis.block

echo "Create the configuration tx"
CHANNEL_NAME=newchannel
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./peer/channel-artifacts/channel.tx -channelID ${CHANNEL_NAME}

echo "Define the anchor peer for Org1 on the channel"
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./peer/channel-artifacts/Org1MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org1MSP
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./peer/channel-artifacts/Org2MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org2MSP
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./peer/channel-artifacts/Org3MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org3MSP

