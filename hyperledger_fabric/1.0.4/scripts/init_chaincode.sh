#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Install chaincode on all peers
echo_b "Installing chaincode on all 4 peers..."
setEnvs 1 0
chaincodeInstall "1-0" ${CC_NAME} ${CC_INIT_VERSION} ${CC_PATH}
setEnvs 1 1
chaincodeInstall "1-1" ${CC_NAME} ${CC_INIT_VERSION} ${CC_PATH}
setEnvs 2 0
chaincodeInstall "2-0" ${CC_NAME} ${CC_INIT_VERSION} ${CC_PATH}
setEnvs 2 1
chaincodeInstall "2-1" ${CC_NAME} ${CC_INIT_VERSION} ${CC_PATH}

# Instantiate chaincode on all peers
# Instantiate can only be executed once on any node
echo_b "Instantiating chaincode on all 2 orgs (once for each org)..."
setEnvs 1 0
chaincodeInstantiate ${CHANNEL_NAME} "1-0" ${CC_NAME} ${CC_INIT_VERSION} ${CC_INIT_ARGS}
setEnvs 2 0
chaincodeInstantiate ${CHANNEL_NAME} "2-0" ${CC_NAME} ${CC_INIT_VERSION} ${CC_INIT_ARGS}

echo
echo_g "===================== Init chaincode done ===================== "
echo

exit 0
