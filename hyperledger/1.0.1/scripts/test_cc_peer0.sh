#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "Channel name : "$CHANNEL_NAME

echo_b "====================Query the existing value of a===================================="
chaincodeQuery 0 100

echo_b "=====================Invoke a transaction to transfer 10 from a to b=================="
chaincodeInvoke 0

sleep 2

echo_b "=====================Check if the result of a is 90==================================="
chaincodeQuery 0 90

echo
echo_g "=====================All GOOD, MVE Test completed ===================== "
echo
exit 0
