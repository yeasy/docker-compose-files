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

echo_b "=== Approve chaincode definition ${CC_NAME} on all organizations ... ==="

for org in "${ORGS[@]}"
do
	t="\${ORG${org}_PEER0_URL}" && peer_url=`eval echo $t`
	t="\${ORG${org}_PEER0_TLS_ROOTCERT}" && peer_tls_rootcert=`eval echo $t`
	chaincodeApprove "$org" 0 ${peer_url} ${peer_tls_rootcert} ${ORDERER0_URL} ${ORDERER0_TLS_ROOTCERT} "${APP_CHANNEL}" ${CC_NAME} ${CC_INIT_VERSION}
done

echo_g "=== Approve chaincode done ==="

echo
