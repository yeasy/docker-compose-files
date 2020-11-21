#!/usr/bin/env bash

# This script will run some qscc queries for testing.

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "CSCC testing"

org=1
peer=0

#peer chaincode query \
#	-C "" \
#	-n cscc \
#	-c '{"Args":["GetConfigBlock","'${APP_CHANNEL}'"]}'

echo_b "CSCC GetConfigBlock"
chaincodeQuery $org $peer "${ORG1_PEER0_URL}" "${ORG1_PEER0_TLS_ROOTCERT}" ${APP_CHANNEL} cscc '{"Args":["GetConfigBlock","'${APP_CHANNEL}'"]}'

echo_b "CSCC GetChannels"
chaincodeQuery $org $peer "${ORG1_PEER0_URL}" "${ORG1_PEER0_TLS_ROOTCERT}" ${APP_CHANNEL} cscc '{"Args":["GetChannels"]}'

echo_g "CSCC testing done!"

echo
