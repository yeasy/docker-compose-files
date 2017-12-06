#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Join all the peers to the channel
echo_b "Having all peers join the channel ${APP_CHANNEL}..."

for org in "${ORGS[@]}"
do
	for peer in "${PEERS[@]}"
	do
		channelJoin ${APP_CHANNEL} $org $peer
	done
done

#channelJoin ${APP_CHANNEL} 1 0
#channelJoin ${APP_CHANNEL} 1 1
#channelJoin ${APP_CHANNEL} 2 0
#channelJoin ${APP_CHANNEL} 2 1