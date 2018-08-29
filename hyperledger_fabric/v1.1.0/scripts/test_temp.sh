#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Install chaincode on all peers
CC_NAME="chaincode01"
CC_PATH="examples/chaincode/go/chaincode01"
CC_INIT_ARGS='{"Args":["init",""]}'
CC_INVOKE_ARGS='{"Args":["createOrder","OD502","OD501","Order_Created"]}'
CC_QUERY_ARGS='{"Args":["queryByParentOrder","OD501"]}'

echo_b "=== Installing chaincode ${CC_NAME} on all 4 peers... ==="

echo before comment
: <<'END'

for org in "${ORGS[@]}"
do
	for peer in "${PEERS[@]}"
	do
		chaincodeInstall $org $peer ${CC_NAME} ${CC_INIT_VERSION} ${CC_PATH}
	done
done

echo_g "=== Install chaincode done ==="

echo_b "Instantiate chaincode"
chaincodeInstantiate "${APP_CHANNEL}" 1 0 ${CC_NAME} ${CC_INIT_VERSION} ${CC_INIT_ARGS}

END

echo_b "Invoke chaincode"
chaincodeInvoke ${APP_CHANNEL} 1 0 ${CC_NAME} ${CC_INVOKE_ARGS}

echo_b "Query chaincode"
chaincodeInvoke ${APP_CHANNEL} 1 0 ${CC_NAME} ${CC_QUERY_ARGS}
