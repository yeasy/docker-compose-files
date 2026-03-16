#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
  source ./func.sh
elif [ -f scripts/func.sh ]; then
  source scripts/func.sh
fi

CC_NAME=${CC_NAME:-$CC_02_NAME}
CC_PATH=${CC_PATH:-$CC_02_PATH}

echo_b "=== Query Approved Chaincode for ${CC_NAME} on all organizations ... ==="

for org in "${ORGS[@]}"; do
  peer=$(getOrgTestPeer "$org")
  peer_url=$(getOrgPeerUrl "$org" "$peer")
  peer_tls_rootcert=$(getOrgPeerTlsRootcert "$org" "$peer")
  chaincodeQueryApproved "$org" "$peer" ${peer_url} ${peer_tls_rootcert} "${APP_CHANNEL}" ${CC_NAME} 1
done

echo_g "=== Query Approved Chaincode done ==="

echo
