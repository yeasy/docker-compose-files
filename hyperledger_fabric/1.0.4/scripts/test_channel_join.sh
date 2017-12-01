#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Join all the peers to the channel
echo_b "Having all peers join the channel ${CHANNEL_NAME}..."

for org in "${ORGS[@]}"
do
	for peer in "${PEERS[@]}"
	do
		channelJoin ${CHANNEL_NAME} $org $peer
	done
done

#channelJoin ${CHANNEL_NAME} 1 0
#channelJoin ${CHANNEL_NAME} 1 1
#channelJoin ${CHANNEL_NAME} 2 0
#channelJoin ${CHANNEL_NAME} 2 1