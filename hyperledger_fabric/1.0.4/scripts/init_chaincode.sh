#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Install chaincode on all peers
echo_b "Installing chaincode on all 4 peers..."
chaincodeInstall 0 1.0
chaincodeInstall 1 1.0
chaincodeInstall 2 1.0
chaincodeInstall 3 1.0

# Instantiate chaincode on all peers
# Instantiate can only be executed once on any node
echo_b "Instantiating chaincode on all 2 orgs (once for each org)..."
chaincodeInstantiate $CHANNEL_NAME 0
chaincodeInstantiate $CHANNEL_NAME 2

echo
echo_g "===================== Init chaincode done ===================== "
echo

exit 0
