#!/usr/bin/env bash

# This script will run some qscc queries for testing.

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "QSCC testing"

org=1
peer=0

#peer chaincode query \
#	-C "" \
#	-n qscc \
#	-c '{"Args":["GetChainInfo","'${APP_CHANNEL}'"]}'

echo_b "QSCC GetChainInfo"
chaincodeQuery ${APP_CHANNEL} $org $peer qscc '{"Args":["GetChainInfo","'${APP_CHANNEL}'"]}'

#peer chaincode query \
#	-C "" \
#	-n qscc \
#	-c '{"Args":["GetBlockByNumber","'${APP_CHANNEL}'","2"]}'

echo_b "QSCC GetBlockByNumber 0"
chaincodeQuery ${APP_CHANNEL} $org $peer qscc '{"Args":["GetBlockByNumber","'${APP_CHANNEL}'","0"]}'

echo_b "QSCC GetBlockByNumber 2"
chaincodeQuery ${APP_CHANNEL} $org $peer qscc '{"Args":["GetBlockByNumber","'${APP_CHANNEL}'","2"]}'

echo_g "QSCC testing done!"

echo
