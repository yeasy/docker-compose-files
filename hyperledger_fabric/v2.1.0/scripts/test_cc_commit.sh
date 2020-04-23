#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Install chaincode on all peers
CC_NAME=${CC_NAME:-$CC_02_NAME}

# Once a sufficient number of organizations (in this case, a majority) have
# approved a chaincode definition, one organization commit the definition to the
# channel.

echo_b "=== Commit chaincode definition ${CC_NAME} to channel ${APP_CHANNEL} ... ==="

chaincodeCommit "${ORGS[0]}" "${PEERS[0]}" "${APP_CHANNEL}" "${ORDERER0_URL}" ${ORDERER0_TLS_ROOTCERT} ${CC_NAME} ${CC_INIT_VERSION}

echo_g "=== Commit Chaincode done, now you can invoke chaincode to start the container ==="

echo
