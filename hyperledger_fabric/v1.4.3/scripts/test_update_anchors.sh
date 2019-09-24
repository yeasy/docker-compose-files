#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Set the anchor peers for each org in the channel
echo_b "=== Updating anchor peers to peer0 for org1... ==="
channelUpdate ${APP_CHANNEL} 1 0 ${ORDERER0_URL}  ${ORDERER0_TLS_ROOTCERT} Org1MSPanchors.tx

echo_b "=== Updating anchor peers to peer0 for org2... ==="
channelUpdate ${APP_CHANNEL} 2 0 ${ORDERER0_URL}  ${ORDERER0_TLS_ROOTCERT} Org2MSPanchors.tx

echo_b "=== Updated anchor peers ==="

echo