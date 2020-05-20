#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

CC_NAME=${CC_NAME:-$CC_02_NAME}
CC_INVOKE_ARGS=${CC_INVOKE_ARGS:-$CC_02_INVOKE_ARGS}
CC_QUERY_ARGS=${CC_QUERY_ARGS:-$CC_02_QUERY_ARGS}

echo_b "Channel name: "${APP_CHANNEL}

echo_b "Query the existing value of a"
chaincodeQuery 1 0 "${ORG1_PEER0_URL}" "${ORG1_PEER0_TLS_ROOTCERT}" ${APP_CHANNEL} ${CC_NAME} ${CC_QUERY_ARGS} 100

sleep 1

echo_b "Invoke a transaction to transfer 10 from a to b"
chaincodeInvoke 1 0 "${ORG1_PEER0_URL}" "${ORG1_PEER0_TLS_ROOTCERT}" ${APP_CHANNEL} "${ORDERER_URL}" ${CC_NAME} ${CC_INVOKE_ARGS}

sleep 1

echo_b "Check if the result of a is 90"
chaincodeQuery 1 0 "${ORG1_PEER0_URL}" "${ORG1_PEER0_TLS_ROOTCERT}" ${APP_CHANNEL} ${CC_NAME} ${CC_QUERY_ARGS} 90

echo
echo_g "All GOOD, MVE Test completed"
echo
exit 0
