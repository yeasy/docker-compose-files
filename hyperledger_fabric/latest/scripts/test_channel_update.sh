#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Join all the peers to the channel
echo_b "=== Updating config of channel ${APP_CHANNEL}... ==="

echo_b "Sign the channel update tx by Org1/Peer0 and Org2/Peer0"
channelSignConfigTx ${APP_CHANNEL} "1" "0" "${CFG_DELTA_ENV_PB}"
channelSignConfigTx ${APP_CHANNEL} "2" "0" "${CFG_DELTA_ENV_PB}"

channelUpdate ${APP_CHANNEL} "1" "0" ${ORDERER0_URL} ${ORDERER0_TLS_ROOTCERT} ${CFG_DELTA_ENV_PB}

sleep 1 # wait till the update takes effect

# use org1.peer0's id to get latest block from orderer
newest_block_file1=/tmp/${APP_CHANNEL}_newest1.block
channelFetch ${APP_CHANNEL} "1" "0" ${ORDERER0_URL} ${ORDERER0_TLS_ROOTCERT} "newest" ${newest_block_file1}
[ -f ${newest_block_file1} ] || exit 1

# use org3.peer0's id to get latest block from orderer
newest_block_file2=/tmp/${APP_CHANNEL}_newest2.block
channelFetch ${APP_CHANNEL} "3" "0" ${ORDERER0_URL} ${ORDERER0_TLS_ROOTCERT} "newest" ${newest_block_file2}
[ -f ${newest_block_file2} ] || exit 1

if [ $(getShasum ${newest_block_file1}) = $(getShasum ${newest_block_file2}) ]; then
	echo_g "Block matched, new org joined channel successfully"
else
	echo_r "Block not matched, new org joined channel failed"
	exit 1
fi

# Now new org is valid to join the channel
# channelJoin ${APP_CHANNEL} "3" "0"

echo_g "=== Updated config of channel ${APP_CHANNEL}... ==="

echo
