#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Join all the peers to the channel
echo_b "Update the channel ${APP_CHANNEL} by adding new Org..."

for org in "${ORGS[@]}"
do
	for peer in "${PEERS[@]}"
	do
		channelJoin ${APP_CHANNEL} $org $peer
	done
done
