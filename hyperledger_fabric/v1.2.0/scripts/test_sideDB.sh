#!/bin/bash
# test sideDB feature: https://jira.hyperledger.org/browse/FAB-10231

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Install chaincode on all peers
CC_NAME=${CC_MARBLES_NAME}
CC_PATH=${CC_MARBLES_PATH}
CC_INIT_ARGS=${CC_MARBLES_INIT_ARGS}

echo_b "=== Testing the private data feature ==="

echo_b "=== Installing chaincode ${CC_NAME} on all 4 peers... ==="

for org in "${ORGS[@]}"
do
	for peer in "${PEERS[@]}"
	do
		chaincodeInstall $org $peer ${CC_NAME} ${CC_INIT_VERSION} ${CC_PATH}
	done
done

echo_g "=== Install chaincode done ==="

# test sideDB feature
chaincodeInstantiate "${APP_CHANNEL}" 1 0 ${CC_NAME} ${CC_INIT_VERSION} ${CC_INIT_ARGS} ${CC_MARBLES_COLLECTION_CONFIG}

echo_g "=== Instantiate chaincode done ==="
# sideDB testing

# both org1 and org2 can invoke, but gossip is the problem to cross org
echo_b "Invoke chaincode with collection on org1/peer0"
chaincodeInvoke ${APP_CHANNEL} 1 0 ${CC_MARBLES_NAME} ${CC_MARBLES_INVOKE_INIT_ARGS}
echo_g "=== Invoke chaincode done ==="

# both org1 and org2 can do normal read
echo_b "Query chaincode with collection collectionMarbles on org1/peer1"
chaincodeQuery ${APP_CHANNEL} 1 1 ${CC_MARBLES_NAME} ${CC_MARBLES_QUERY_READ_ARGS}
echo_g "=== Query read chaincode done ==="

# only org1 can do detailed read
echo_b "Query chaincode with collection collectionMarblePrivateDetails on org1/peer1"
chaincodeQuery ${APP_CHANNEL} 1 1 ${CC_MARBLES_NAME} ${CC_MARBLES_QUERY_READPVTDETAILS_ARGS}
echo_g "=== Query read details chaincode done ==="

echo_b "Install chaincode with new collection config"
for org in "${ORGS[@]}"
do
	for peer in "${PEERS[@]}"
	do
		chaincodeInstall $org $peer ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_PATH}
	done
done

chaincodeUpgrade ${APP_CHANNEL} 1 0 ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_INIT_ARGS} ${CC_MARBLES_COLLECTION_CONFIG_NEW}

echo