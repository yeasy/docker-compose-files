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
ORG1_TEST_PEER_INDEX=$(getOrgTestPeer 1)
ORG2_TEST_PEER_INDEX=$(getOrgTestPeer 2)
ORG1_TEST_PEER_URL=$(getOrgPeerUrl 1 "${ORG1_TEST_PEER_INDEX}")
ORG1_TEST_PEER_TLS_ROOTCERT=$(getOrgPeerTlsRootcert 1 "${ORG1_TEST_PEER_INDEX}")
ORG2_TEST_PEER_URL=$(getOrgPeerUrl 2 "${ORG2_TEST_PEER_INDEX}")
ORG2_TEST_PEER_TLS_ROOTCERT=$(getOrgPeerTlsRootcert 2 "${ORG2_TEST_PEER_INDEX}")

echo_b "=== Testing Chaincode invoke/query ==="

echo_b "Init chaincode by org1/peer${ORG1_TEST_PEER_INDEX}..."
chaincodeInit 1 "${ORG1_TEST_PEER_INDEX}" ${APP_CHANNEL} "${ORDERER0_URL}" ${CC_NAME} ${CC_INIT_ARGS} "${ORG1_TEST_PEER_URL}" "${ORG1_TEST_PEER_TLS_ROOTCERT}"

sleep 5 # wait for chaincode is up

# Non-side-DB testing
echo_b "Query chaincode ${CC_NAME} on peer org1/peer${ORG1_TEST_PEER_INDEX}..."
chaincodeQuery 1 "${ORG1_TEST_PEER_INDEX}" "${ORG1_TEST_PEER_URL}" "${ORG1_TEST_PEER_TLS_ROOTCERT}" ${APP_CHANNEL} ${CC_NAME} ${CC_QUERY_ARGS} 100

echo_b "Invoke transaction (transfer 10) by org1/peer${ORG1_TEST_PEER_INDEX}..."
chaincodeInvoke 1 "${ORG1_TEST_PEER_INDEX}" "${ORG1_TEST_PEER_URL}" "${ORG1_TEST_PEER_TLS_ROOTCERT}" ${APP_CHANNEL} "${ORDERER0_URL}" ${ORDERER0_TLS_ROOTCERT} ${CC_NAME} ${CC_INVOKE_ARGS}

echo_b "Query chaincode on org2/peer${ORG2_TEST_PEER_INDEX}..."
chaincodeQuery 2 "${ORG2_TEST_PEER_INDEX}" "${ORG2_TEST_PEER_URL}" "${ORG2_TEST_PEER_TLS_ROOTCERT}" ${APP_CHANNEL} ${CC_NAME} ${CC_QUERY_ARGS} 90

echo_b "Send invoke transaction on org2/peer${ORG2_TEST_PEER_INDEX}..."
chaincodeInvoke 2 "${ORG2_TEST_PEER_INDEX}" "${ORG2_TEST_PEER_URL}" "${ORG2_TEST_PEER_TLS_ROOTCERT}" ${APP_CHANNEL} "${ORDERER0_URL}" ${ORDERER0_TLS_ROOTCERT} ${CC_NAME} ${CC_INVOKE_ARGS}

echo_b "Query chaincode on org1/peer${ORG1_TEST_PEER_INDEX}..."
chaincodeQuery 1 "${ORG1_TEST_PEER_INDEX}" "${ORG1_TEST_PEER_URL}" "${ORG1_TEST_PEER_TLS_ROOTCERT}" ${APP_CHANNEL} ${CC_NAME} ${CC_QUERY_ARGS} 80

echo_g "=== Chaincode invoke/query done ==="
