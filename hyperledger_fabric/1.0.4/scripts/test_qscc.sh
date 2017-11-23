#!/usr/bin/env bash

# This script will run some qscc queries for testing.

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "QSCC testing"

echo_b "QSCC GetChainInfo"
chaincodeQuery "" 0 qscc '{"Args":["GetChainInfo","'${CHANNEL_NAME}'"]}'

echo_b "QSCC GetBlockByNumber 2"
chaincodeQuery "" 0 qscc '{"Args":["GetBlockByNumber","'${CHANNEL_NAME}'","2"]}'

#peer chaincode query \
#	-C "" \
#	-n qscc \
#	-c '{"Args":["GetChainInfo","'${CHANNEL_NAME}'"]}'

#peer chaincode query \
#	-C "" \
#	-n qscc \
#	-c '{"Args":["GetBlockByNumber","'${CHANNEL_NAME}'","2"]}'

echo_g "QSCC testing done!"