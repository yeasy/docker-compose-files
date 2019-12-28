#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Query the installed chaincode on all peers
echo_b "=== Query Chaincode installed on all organizations ... ==="

for org in "${ORGS[@]}"
do
	t="\${ORG${org}_PEER0_URL}" && peer_url=`eval echo $t`
	t="\${ORG${org}_PEER0_TLS_ROOTCERT}" && peer_tls_rootcert=`eval echo $t`
	chaincodeQueryInstalled "$org" 0 ${peer_url} ${peer_tls_rootcert}
done

echo_g "=== Query Chaincode installed status done ==="

echo
