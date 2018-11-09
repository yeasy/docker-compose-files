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
chaincodeQuery ${APP_CHANNEL} $org $peer cscc '{"Args":["GetConfigBlock","'${APP_CHANNEL}'"]}'

echo_b "CSCC GetChannels"
chaincodeQuery ${APP_CHANNEL} $org $peer cscc '{"Args":["GetChannels"]}'

echo_b "CSCC GetConfigTree"
chaincodeQuery ${APP_CHANNEL} $org $peer cscc '{"Args":["GetConfigTree","'${APP_CHANNEL}'"]}'

echo_g "CSCC testing done!"

echo
