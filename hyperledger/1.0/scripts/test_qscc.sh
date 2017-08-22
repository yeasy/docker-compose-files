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


#CHANNEL_NAME="$1"
#: ${CHANNEL_NAME:="businesschannel"}

echo_b "Qscc GetChainInfo"

peer chaincode query -C "" -n qscc -c '{"Args":["GetChainInfo","businesschannel"]}'

peer chaincode query -C "" -n qscc -c '{"Args":["GetBlockByNumber","businesschannel","5"]}'

echo_g "Qscc testing done!"