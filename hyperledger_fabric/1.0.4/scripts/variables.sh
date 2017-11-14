#!/usr/bin/env bash

# Define some global variables for usage. Will be included by func.sh.

# Name of app channel, need to align with the gen_artifacts.sh
CHANNEL_NAME="businesschannel"

# Client cmd execute timeout
TIMEOUT="60"

MAX_RETRY=5

# MSP related paths
ORDERER_TLS_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
ORDERER_MSP=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp

ORG1_PEER0_TLS_ROOTCERT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
ORG2_PEER0_TLS_ROOTCERT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
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
CC_PATH="github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02"
CC_INIT_ARGS='{"Args":["init","a","100","b","200"]}'
CC_INIT_VERSION=1.0
CC_UPGRADE_ARGS='{"Args":["upgrade","a","100","b","200"]}'
CC_UPGRADE_VERSION=1.1
CC_INVOKE_ARGS='{"Args":["invoke","a","b","10"]}'
CC_QUERY_ARGS='{"Args":["query","a"]}'

# TLS config
: ${CORE_PEER_TLS_ENABLED:="false"}
