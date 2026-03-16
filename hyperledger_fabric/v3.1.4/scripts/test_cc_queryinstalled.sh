#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
  source ./func.sh
elif [ -f scripts/func.sh ]; then
  source scripts/func.sh
fi

## Query the installed chaincode on all peers
echo_b "=== Query Chaincode installed on all organizations ... ==="

for org in "${ORGS[@]}"; do
  peer=$(getOrgTestPeer "$org")
  peer_url=$(getOrgPeerUrl "$org" "$peer")
  peer_tls_rootcert=$(getOrgPeerTlsRootcert "$org" "$peer")
  chaincodeQueryInstalled "$org" "$peer" ${peer_url} ${peer_tls_rootcert}
done

echo_g "=== Query Chaincode installed status done ==="

echo
