#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ../../v1.1.0/scripts/func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "=== List chaincode on all peer0.org1... ==="

chaincodeList 1 0 ${APP_CHANNEL}

echo_g "=== List chaincode done ==="

echo
