#!/usr/bin/env bash
# Before running `make`, config this files
# Define some global variables for usage. Will be included by func.sh.

# Name of app channel, need to align with the gen_artifacts.sh
SYS_CHANNEL="testchainid"
APP_CHANNEL="businesschannel"

# Client cmd execute timeout and retry times
TIMEOUT="30"
MAX_RETRY=5

# Organization and peers
ORGS=( 1 2 )
PEERS=( 0 1 )

# MSP related paths
ORDERER_TLS_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
ORDERER_MSP=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp

ORDERER_TLS_ROOTCERT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
ORG1_PEER0_TLS_ROOTCERT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
ORG1_PEER1_TLS_ROOTCERT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
ORG2_PEER0_TLS_ROOTCERT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
ORG2_PEER1_TLS_ROOTCERT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt

ORDERER_ADMIN_MSP=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp
ORG1_ADMIN_MSP=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
ORG2_ADMIN_MSP=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

# Node URLS
ORDERER_URL="orderer.example.com:7050"
ORG1_PEER0_URL="peer0.org1.example.com:7051"
ORG1_PEER1_URL="peer1.org1.example.com:7051"
ORG2_PEER0_URL="peer0.org2.example.com:7051"
ORG2_PEER1_URL="peer1.org2.example.com:7051"

# Chaincode related
CC_NAME="mycc"
#CC_PATH="github.com/hyperledger/fabric/examples/chaincode/go/foodchain"
CC_PATH="examples/chaincode/go/chaincode_example02"
CC_INIT_VERSION=1.0
CC_UPGRADE_VERSION=1.1

CC_INIT_ARGS='{"Args":["init","a","100","b","200"]}'
CC_UPGRADE_ARGS='{"Args":["upgrade","a","100","b","200"]}'
CC_INVOKE_ARGS='{"Args":["invoke","a","b","10"]}'
CC_QUERY_ARGS='{"Args":["query","a"]}'

# TLS config
: ${CORE_PEER_TLS_ENABLED:="false"}

# Generate configs
APP_CHANNEL_TX=channel.tx
ORDERER_GENESIS=orderer.genesis.block
GEN_IMG=yeasy/hyperledger-fabric:1.0.4  # working dir is `/go/src/github.com/hyperledger/fabric`
GEN_CONTAINER=generator
FABRIC_CFG_PATH=/etc/hyperledger/fabric
CHANNEL_ARTIFACTS=channel-artifacts
CRYPTO_CONFIG=crypto-config

# CONFIGTXLATOR
CTL_IMG=yeasy/hyperledger-fabric:1.0.4
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
MAX_BATCH_SIZE_PATH=".data.data[0].payload.data.config.channel_group.groups.Orderer.values.BatchSize.value.max_message_count"
