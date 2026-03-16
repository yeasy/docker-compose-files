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

echo_b "=== Query Chaincode approve status ${CC_NAME} on all organizations ... ==="

for org in "${ORGS[@]}"; do
  peer=$(getOrgTestPeer "$org")
  peer_url=$(getOrgPeerUrl "$org" "$peer")
  peer_tls_rootcert=$(getOrgPeerTlsRootcert "$org" "$peer")
  chaincodeCheckCommitReadiness "$org" "$peer" ${peer_url} ${peer_tls_rootcert} "${APP_CHANNEL}" ${CC_NAME} ${CC_INIT_VERSION} 1
done

echo_g "=== Query Chaincode approve status done ==="

echo
