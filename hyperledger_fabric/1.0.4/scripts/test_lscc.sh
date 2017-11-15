#!/usr/bin/env bash

# This script will run some lscc queries for testing.

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "LSCC testing"

# invoke required following params
	#-o orderer.example.com:7050 \
	#--tls "true" \
	#--cafile ${ORDERER_TLS_CA} \

setGlobals 0

echo_b "Get id"
peer chaincode query \
	-C "${CHANNEL_NAME}" \
	-n lscc \
	-c '{"Args":["getid","'${CHANNEL_NAME}'", "mycc"]}'

echo_b "Get cc ChaincodeDeploymentSpec"
peer chaincode query \
	-C "${CHANNEL_NAME}" \
	-n lscc \
	-c '{"Args":["getdepspec","'${CHANNEL_NAME}'", "mycc"]}'

echo_b "Get cc bytes"
peer chaincode query \
	-C "${CHANNEL_NAME}" \
	-n lscc \
  -c '{"Args":["getccdata","'${CHANNEL_NAME}'", "mycc"]}'

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