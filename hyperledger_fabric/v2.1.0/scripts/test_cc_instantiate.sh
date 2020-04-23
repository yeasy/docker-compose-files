#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

CC_NAME=${CC_NAME:-$CC_02_NAME}
CC_INIT_ARGS=${CC_INIT_ARGS:-$CC_02_INIT_ARGS}

# Instantiate chaincode in the channel, executed once on any node is enough
# (once for each channel is enough, we make it concurrent here)
echo_b "=== Instantiating chaincode on channel ${APP_CHANNEL}... ==="

# Instantiate at org1.peer0 and org2.peer0, actually it can be triggered once per channel
chaincodeInstantiate "${APP_CHANNEL}" 1 0 ${ORDERER0_URL} ${CC_NAME} ${CC_INIT_VERSION} ${CC_INIT_ARGS}
#chaincodeInstantiate "${APP_CHANNEL}" 2 0 ${ORDERER0_URL} ${CC_NAME} ${CC_INIT_VERSION} ${CC_INIT_ARGS}

echo_g "=== Instantiate chaincode on channel ${APP_CHANNEL} done ==="

echo