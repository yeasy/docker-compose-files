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

CC_NAME=${CC_02_NAME}

echo_b "LSCC Get id"
chaincodeQuery "${APP_CHANNEL}" $org $peer lscc '{"Args":["getid","'${APP_CHANNEL}'", "'${CC_NAME}'"]}'

echo_b "LSCC Get cc ChaincodeDeploymentSpec"
chaincodeQuery "${APP_CHANNEL}" $org $peer lscc '{"Args":["getdepspec","'${APP_CHANNEL}'", "'${CC_NAME}'"]}'

echo_b "LSCC Get cc bytes"
chaincodeQuery "${APP_CHANNEL}" $org $peer lscc '{"Args":["getccdata","'${APP_CHANNEL}'", "'${CC_NAME}'"]}'

echo_b "LSCC Get all chaincodes installed on the peer"
chaincodeQuery "${APP_CHANNEL}" $org $peer lscc '{"Args":["getinstalledchaincodes"]}'

echo_b "LSCC Get all chaincodes instantiated on the channel"
chaincodeQuery "${APP_CHANNEL}" $org $peer lscc '{"Args":["getchaincodes"]}'


#peer chaincode query \
#	-C "${APP_CHANNEL}" \
#	-n lscc \
#	-c '{"Args":["getid","'${APP_CHANNEL}'", "'$CC_NAME'"]}'

#peer chaincode query \
#	-C "${APP_CHANNEL}" \
#	-n lscc \
#	-c '{"Args":["getdepspec","'${APP_CHANNEL}'", "'$CC_NAME'"]}'

#peer chaincode query \
#	-C "${APP_CHANNEL}" \
#	-n lscc \
#  -c '{"Args":["getccdata","'${APP_CHANNEL}'", "'$CC_NAME'"]}'

#peer chaincode query \
#	-C "${APP_CHANNEL}" \
#	-n lscc \
#	-c '{"Args":["getinstalledchaincodes"]}'

#peer chaincode query \
#	-C "${APP_CHANNEL}" \
#	-n lscc \
#	-c '{"Args":["getchaincodes"]}'

echo_g "LSCC testing done!"

echo
