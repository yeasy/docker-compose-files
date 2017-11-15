#!/usr/bin/env bash

# This script will run some qscc queries for testing.

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

setGlobals 0

echo_b "QSCC GetChainInfo"
peer chaincode query \
	-C "" \
	-n qscc \
	-c '{"Args":["GetChainInfo","'${CHANNEL_NAME}'"]}'

echo_b "QSCC GetBlockByNumber 2"
peer chaincode query \
	-C "" \
	-n qscc \
	-c '{"Args":["GetBlockByNumber","'${CHANNEL_NAME}'","2"]}'

echo_g "Qscc testing done!"