#!/usr/bin/env bash

# This script will run some lscc queries for testing.

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "LSCC testing"

org=1
peer=0

# invoke required following params
	#-o orderer.example.com:7050 \
	#--tls "true" \
	#--cafile ${ORDERER_TLS_CA} \

echo_b "LSCC Get id"
chaincodeQuery "${CHANNEL_NAME}" $org $peer lscc '{"Args":["getid","'${CHANNEL_NAME}'", "'$CC_NAME'"]}'

echo_b "LSCC Get cc ChaincodeDeploymentSpec"
chaincodeQuery "${CHANNEL_NAME}" $org $peer lscc '{"Args":["getdepspec","'${CHANNEL_NAME}'", "'$CC_NAME'"]}'

echo_b "LSCC Get cc bytes"
chaincodeQuery "${CHANNEL_NAME}" $org $peer lscc '{"Args":["getccdata","'${CHANNEL_NAME}'", "'$CC_NAME'"]}'

echo_b "LSCC Get all chaincodes installed on the channel"
chaincodeQuery "${CHANNEL_NAME}" $org $peer lscc '{"Args":["getinstalledchaincodes"]}'

echo_b "LSCC Get all chaincodes instantiated on the channel"
chaincodeQuery "${CHANNEL_NAME}" $org $peer lscc '{"Args":["getchaincodes"]}'


#peer chaincode query \
#	-C "${CHANNEL_NAME}" \
#	-n lscc \
#	-c '{"Args":["getid","'${CHANNEL_NAME}'", "'$CC_NAME'"]}'

#peer chaincode query \
#	-C "${CHANNEL_NAME}" \
#	-n lscc \
#	-c '{"Args":["getdepspec","'${CHANNEL_NAME}'", "'$CC_NAME'"]}'

#peer chaincode query \
#	-C "${CHANNEL_NAME}" \
#	-n lscc \
#  -c '{"Args":["getccdata","'${CHANNEL_NAME}'", "'$CC_NAME'"]}'

#peer chaincode query \
#	-C "${CHANNEL_NAME}" \
#	-n lscc \
#	-c '{"Args":["getinstalledchaincodes"]}'

#peer chaincode query \
#	-C "${CHANNEL_NAME}" \
#	-n lscc \
#	-c '{"Args":["getchaincodes"]}'

echo_g "LSCC testing done!"