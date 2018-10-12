#!/usr/bin/env bash

# Use ${FABRIC_CFG_PATH}/configtx.yaml to generate following materials,
# and put under /tmp/$CHANNEL_ARTIFACTS:
# system channel genesis block
# new app channel tx
# update anchor peer tx

# Define those global variables
if [ -f ./variables.sh ]; then
 source ./variables.sh
elif [ -f /scripts/variables.sh ]; then
 source /scripts/variables.sh
else
	echo "Cannot find the variables.sh files, pls check"
	exit 1
fi

cd /tmp/${CHANNEL_ARTIFACTS}  # all generated materials will be put under /tmp/$CHANNEL_ARTIFACTS

echo "Generate genesis block for system channel using configtx.yaml"
configtxgen \
	-configPath /tmp \
	-channelID ${SYS_CHANNEL} \
	-profile ${ORDERER_GENESIS_PROFILE} \
	-outputBlock ${ORDERER_GENESIS}

echo "Create the new app channel tx using configtx.yaml"
configtxgen \
	-configPath /tmp \
	-profile ${APP_CHANNEL_PROFILE} \
	-channelID ${APP_CHANNEL} \
	-outputCreateChannelTx ${APP_CHANNEL_TX}
configtxgen \
	-inspectChannelCreateTx ${APP_CHANNEL_TX} > ${APP_CHANNEL_TX}.json

echo "Create the anchor peer configuration tx for org1 and org2"
configtxgen \
	-configPath /tmp \
	-profile ${APP_CHANNEL_PROFILE} \
	-channelID ${APP_CHANNEL} \
	-asOrg ${ORG1MSP} \
	-outputAnchorPeersUpdate ${UPDATE_ANCHOR_ORG1_TX}

configtxgen \
	-configPath /tmp \
	-profile ${APP_CHANNEL_PROFILE} \
	-channelID ${APP_CHANNEL} \
	-asOrg ${ORG2MSP} \
	-outputAnchorPeersUpdate ${UPDATE_ANCHOR_ORG2_TX}

echo "Output the json for org1, org2 and org3"
configtxgen \
	-configPath /tmp \
	-printOrg ${ORG1MSP} >${ORG1MSP}.json

configtxgen \
	-configPath /tmp \
	-printOrg ${ORG2MSP} >${ORG2MSP}.json

configtxgen \
	-configPath /tmp/org3/ \
	-printOrg ${ORG3MSP} >${ORG3MSP}.json
