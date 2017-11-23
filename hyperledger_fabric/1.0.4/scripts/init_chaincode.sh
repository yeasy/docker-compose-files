#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Install chaincode on all peers
echo_b "Installing chaincode on all 4 peers..."
setEnvs "Org1MSP" ${ORG1_PEER0_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER0_URL}
chaincodeInstall 0 ${CC_NAME} ${CC_INIT_VERSION} ${CC_PATH}
setEnvs "Org1MSP" ${ORG1_PEER1_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER1_URL}
chaincodeInstall 1 ${CC_NAME} ${CC_INIT_VERSION} ${CC_PATH}
setEnvs "Org2MSP" ${ORG2_PEER0_TLS_ROOTCERT} ${ORG2_ADMIN_MSP} ${ORG2_PEER0_URL}
chaincodeInstall 2 ${CC_NAME} ${CC_INIT_VERSION} ${CC_PATH}
setEnvs "Org2MSP" ${ORG2_PEER1_TLS_ROOTCERT} ${ORG2_ADMIN_MSP} ${ORG2_PEER1_URL}
chaincodeInstall 3 ${CC_NAME} ${CC_INIT_VERSION} ${CC_PATH}

# Instantiate chaincode on all peers
# Instantiate can only be executed once on any node
echo_b "Instantiating chaincode on all 2 orgs (once for each org)..."
setEnvs "Org1MSP" ${ORG1_PEER0_TLS_ROOTCERT} ${ORG1_ADMIN_MSP} ${ORG1_PEER0_URL}
chaincodeInstantiate ${CHANNEL_NAME} 0 ${CC_NAME} ${CC_INIT_VERSION} ${CC_INIT_ARGS}
setEnvs "Org2MSP" ${ORG2_PEER0_TLS_ROOTCERT} ${ORG2_ADMIN_MSP} ${ORG2_PEER0_URL}
chaincodeInstantiate ${CHANNEL_NAME} 2 ${CC_NAME} ${CC_INIT_VERSION} ${CC_INIT_ARGS}

echo
echo_g "===================== Init chaincode done ===================== "
echo

exit 0
