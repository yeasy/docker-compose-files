#!/usr/bin/env bash

# This script will run some qscc queries for testing.

# Detecting whether can import the header file to render colorful cli output
# Need add choice option
if [ -f ./header.sh ]; then
 source ./header.sh
elif [ -f scripts/header.sh ]; then
 source scripts/header.sh
else
 alias echo_r="echo"
 alias echo_g="echo"
 alias echo_b="echo"
fi

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="businesschannel"}

echo_b "LSCC testing"

# invoke required following params
	#-o orderer.example.com:7050 \
	#--tls "true" \
	#--cafile ${ORDERER_CA} \

echo_b "Get id"
peer chaincode query \
	-C "${CHANNEL_NAME}" \
	-n lscc \
	-c '{"Args":["getid","businesschannel", "mycc"]}'

echo_b "Get cc ChaincodeDeploymentSpec"
peer chaincode query \
	-C "${CHANNEL_NAME}" \
	-n lscc \
	-c '{"Args":["getdepspec","businesschannel", "mycc"]}'

echo_b "Get cc bytes"
peer chaincode query \
	-C "${CHANNEL_NAME}" \
	-n lscc \
  -c '{"Args":["getccdata","businesschannel", "mycc"]}'

echo_b "Get all chaincodes installed on the channel"
peer chaincode query \
	-C "${CHANNEL_NAME}" \
	-n lscc \
	-c '{"Args":["getinstalledchaincodes"]}'

echo_b "Get all chaincodes instantiated on the channel"
peer chaincode query \
	-C "${CHANNEL_NAME}" \
	-n lscc \
	-c '{"Args":["getchaincodes"]}'

echo_g "LSCC testing done!"