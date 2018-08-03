#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Create channel
echo_b "=== Listing joined channels... ==="

for org in "${ORGS[@]}"
do
	for peer in "${PEERS[@]}"
	do
		channelList $org $peer
	done
done

echo_g "=== Done listing joined channels ==="

echo
