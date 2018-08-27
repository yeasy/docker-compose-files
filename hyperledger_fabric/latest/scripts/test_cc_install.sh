#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Install chaincode on all peers
CC_NAME=${CC_NAME:-$CC_02_NAME}
CC_PATH=${CC_PATH:-$CC_02_PATH}

echo_b "=== Installing chaincode ${CC_NAME} on all 4 peers... ==="

for org in "${ORGS[@]}"
do
	for peer in "${PEERS[@]}"
	do
		chaincodeInstall $org $peer ${CC_NAME} ${CC_INIT_VERSION} ${CC_PATH}
	done
done

echo_g "=== Install chaincode done ==="

echo
