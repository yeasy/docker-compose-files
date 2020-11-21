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

echo "Generate genesis block of system channel using configtx.yaml"
[ ! -f ${ORDERER0_GENESIS_BLOCK} ] && \
configtxgen \
	-configPath /tmp \
	-channelID ${SYS_CHANNEL} \
	-profile ${ORDERER_GENESIS_PROFILE} \
	-outputBlock ${ORDERER0_GENESIS_BLOCK}
[ ! -f ${ORDERER0_GENESIS_BLOCK} ] && echo "Fail to generate genesis block ${ORDERER0_GENESIS_BLOCK}" && exit -1
cp ${ORDERER0_GENESIS_BLOCK} ${ORDERER1_GENESIS_BLOCK}
cp ${ORDERER0_GENESIS_BLOCK} ${ORDERER2_GENESIS_BLOCK}

#for (( i=1; i<150; i++ ));
#do
#APP_CHANNEL="channel"$i
#APP_CHANNEL_TX=${APP_CHANNEL}".tx"
echo "Create the new app channel ${APP_CHANNEL} tx using configtx.yaml"
[ ! -f ${APP_CHANNEL_TX} ] && \
configtxgen \
	-configPath /tmp \
	-profile ${APP_CHANNEL_PROFILE} \
	-channelID ${APP_CHANNEL} \
	-outputCreateChannelTx ${APP_CHANNEL_TX}
[ ! -f ${APP_CHANNEL_TX} ] && echo "Fail to generate app channel tx file" && exit -1
#done

[ ! -f ${APP_CHANNEL_TX}.json ] && \
configtxgen \
	-inspectChannelCreateTx ${APP_CHANNEL_TX} > ${APP_CHANNEL_TX}.json

echo "Create the anchor peer configuration tx for org1 and org2"
[ ! -f ${UPDATE_ANCHOR_ORG1_TX} ] && \
configtxgen \
	-configPath /tmp \
	-profile ${APP_CHANNEL_PROFILE} \
	-channelID ${APP_CHANNEL} \
	-asOrg ${ORG1MSP} \
	-outputAnchorPeersUpdate ${UPDATE_ANCHOR_ORG1_TX}

[ ! -f ${UPDATE_ANCHOR_ORG1_TX} ] && echo "Fail to generate the anchor update tx for org1" && exit -1

[ ! -f ${UPDATE_ANCHOR_ORG2_TX} ] && \
configtxgen \
	-configPath /tmp \
	-profile ${APP_CHANNEL_PROFILE} \
	-channelID ${APP_CHANNEL} \
	-asOrg ${ORG2MSP} \
	-outputAnchorPeersUpdate ${UPDATE_ANCHOR_ORG2_TX}

[ ! -f ${UPDATE_ANCHOR_ORG2_TX} ] && echo "Fail to generate the anchor update tx for org1" && exit -1

echo "Output the json for org1, org2 and org3"
declare -a msps=("${ORG1MSP}"
				"${ORG2MSP}"
				"${ORG3MSP}")
for msp in "${msps[@]}"
do
[ ! -f ${msp}.json ] && \
configtxgen \
	-configPath /tmp \
	-printOrg ${msp} >${msp}.json
done
