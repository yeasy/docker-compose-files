#!/usr/bin/env bash
# Before running `make`, config this files
# Define some global variables for usage. Will be included by func.sh.

# Name of app channel, need to align with the gen_artifacts.sh
SYS_CHANNEL="testchainid"
APP_CHANNEL="businesschannel"

# Client cmd execute timeout and retry times
TIMEOUT="60"
MAX_RETRY=10

# Organization and peers
ORGS=( 1 2 )
PEERS=( 0 1 )
#: "${ORGS:=( 1 2 )}"
#: "${PEERS:=( 0 1 )}"

ORG1MSP="Org1MSP"
ORG2MSP="Org2MSP"
ORG3MSP="Org3MSP"

# MSP related paths
ORDERER_MSP=/etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp
ORDERER_ADMIN_MSP=/etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp
ORG1_ADMIN_MSP=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
ORG1_PEER0_MSP=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.Org1.example.com/msp
ORG2_ADMIN_MSP=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

# cert related path
ORDERER_TLS_CA=/etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
ORDERER_TLS_ROOTCERT=/etc/hyperledger/fabric/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
ORG1_PEER0_TLS_ROOTCERT=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
ORG1_PEER1_TLS_ROOTCERT=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
ORG1_ADMIN_TLS_CLIENT_KEY=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@Org1.example.com/tls/client.key
ORG1_ADMIN_TLS_CLIENT_CERT=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@Org1.example.com/tls/client.crt
ORG1_ADMIN_TLS_CA_CERT=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org1.example.com/users/Admin@Org1.example.com/tls/ca.crt
ORG2_PEER0_TLS_ROOTCERT=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
ORG2_PEER1_TLS_ROOTCERT=/etc/hyperledger/fabric/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt

# Node URLS
ORDERER_URL="orderer.example.com:7050"
ORG1_PEER0_URL="peer0.org1.example.com:7051"
ORG1_PEER1_URL="peer1.org1.example.com:7051"
ORG2_PEER0_URL="peer0.org2.example.com:7051"
ORG2_PEER1_URL="peer1.org2.example.com:7051"

# Chaincode exp02 related
CC_02_NAME="exp02"
CC_02_PATH="examples/chaincode/go/chaincode_example02"
CC_02_INIT_ARGS='{"Args":["init","a","100","b","200"]}'
CC_02_UPGRADE_ARGS='{"Args":["upgrade","a","100","b","200"]}'
CC_02_INVOKE_ARGS='{"Args":["invoke","a","b","10"]}'
CC_02_QUERY_ARGS='{"Args":["query","a"]}'

# Chaincode map related
CC_MAP_NAME="map"
CC_MAP_PATH="examples/chaincode/go/map"
CC_MAP_INIT_ARGS='{"Args":["init",""]}'
CC_MAP_UPGRADE_ARGS='{"Args":["upgrade",""]}'
CC_MAP_INVOKE_ARGS='{"Args":["invoke","put","key","value"]}'
CC_MAP_QUERY_ARGS='{"Args":["get","key"]}'

# Chaincode marbles related
CC_MARBLES_NAME="marblesp"
CC_MARBLES_PATH="examples/chaincode/go/marbles02_private/go"
CC_MARBLES_INIT_ARGS='{"Args":["init"]}'
CC_MARBLES_UPGRADE_ARGS='{"Args":["upgrade",""]}'
CC_MARBLES_INVOKE_INIT_ARGS='{"Args":["initMarble","marble1","blue","10","tom","100"]}' # price is in collectionMarblePrivateDetails
CC_MARBLES_INVOKE_TRANSFER_ARGS='{"Args":["transferMarble","marble1","jerry"]}' # price is in collectionMarblePrivateDetails
CC_MARBLES_QUERY_READ_ARGS='{"Args":["readMarble","marble1"]}' # this requires 'collectionMarbles' collection
CC_MARBLES_QUERY_READPVTDETAILS_ARGS='{"Args":["readMarblePrivateDetails","marble1"]}' # this requires 'collectionMarblePrivateDetails' collection
CC_MARBLES_COLLECTION_CONFIG="/go/src/examples/chaincode/go/marbles02_private/collections_config.json"
CC_MARBLES_COLLECTION_CONFIG_NEW="/go/src/examples/chaincode/go/marbles02_private/collections_config_new.json"

# unique chaincode params
CC_NAME=${CC_02_NAME}
CC_PATH=${CC_02_PATH}
CC_INIT_ARGS=${CC_02_INIT_ARGS}
CC_INIT_VERSION=1.0
CC_UPGRADE_ARGS=${CC_02_UPGRADE_ARGS}
CC_UPGRADE_VERSION=1.1
CC_INVOKE_ARGS=${CC_02_INVOKE_ARGS}
CC_QUERY_ARGS=${CC_02_QUERY_ARGS}

# Generate configs
GEN_IMG=yeasy/hyperledger-fabric:${FABRIC_IMG_TAG}  # working dir is `/go/src/github.com/hyperledger/fabric`
GEN_CONTAINER=generator
FABRIC_CFG_PATH=/etc/hyperledger/fabric
CHANNEL_ARTIFACTS=channel-artifacts
CRYPTO_CONFIG=crypto-config
ORDERER_GENESIS=orderer.genesis.block
ORDERER_GENESIS_PROFILE=TwoOrgsOrdererGenesis
APP_CHANNEL_PROFILE=TwoOrgsChannel
APP_CHANNEL_TX=${APP_CHANNEL}.tx
UPDATE_ANCHOR_ORG1_TX=Org1MSPanchors.tx
UPDATE_ANCHOR_ORG2_TX=Org2MSPanchors.tx

# CONFIGTXLATOR
CTL_IMG=yeasy/hyperledger-fabric:${FABRIC_IMG_TAG}
CTL_CONTAINER=configtxlator
CTL_BASE_URL=http://127.0.0.1:7059
CTL_ENCODE_URL=${CTL_BASE_URL}/protolator/encode
CTL_DECODE_URL=${CTL_BASE_URL}/protolator/decode
CTL_COMPARE_URL=${CTL_BASE_URL}/configtxlator/compute/update-from-configs

ORDERER_GENESIS_JSON=${ORDERER_GENESIS}.json
ORDERER_GENESIS_PAYLOAD_JSON=${ORDERER_GENESIS}_payload.json
ORDERER_GENESIS_UPDATED_BLOCK=orderer.genesis.updated.block
ORDERER_GENESIS_UPDATED_JSON=${ORDERER_GENESIS_UPDATED_BLOCK}.json
PAYLOAD_PATH=".data.data[0].payload"
PAYLOAD_CFG_PATH=".data.data[0].payload.data.config"
MAX_BATCH_SIZE_PATH=".data.data[0].payload.data.config.channel_group.groups.Orderer.values.BatchSize.value.max_message_count"

# channel update config
ORIGINAL_CFG_JSON=original_config.json
ORIGINAL_CFG_PB=original_config.pb
UPDATED_CFG_JSON=updated_config.json
UPDATED_CFG_PB=updated_config.pb
CFG_DELTA_JSON=config_delta.json
CFG_DELTA_PB=config_delta.pb
CFG_DELTA_ENV_JSON=config_delta_env.json
CFG_DELTA_ENV_PB=config_delta_env.pb

#ARCH=x86_64
ARCH=amd64

# for the base images, including baseimage, baseos, couchdb, kafka, zookeeper
BASE_IMG_TAG=0.4.10

# For fabric images, including peer, orderer, ca
FABRIC_IMG_TAG=1.2.0

PROJECT_VERSION=1.2.0