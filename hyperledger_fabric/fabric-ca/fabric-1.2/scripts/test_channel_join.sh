#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Join all the peers to the channel
echo_b "=== Join peers ${PEERS} from org ${ORGS} into ${APP_CHANNEL}... ==="

for org in "${ORGS[@]}"
do
	for peer in "${PEERS[@]}"
	do
		channelJoin ${APP_CHANNEL} $org $peer
	done
done

echo_g "=== Join peers ${PEERS} from org ${ORGS} into ${APP_CHANNEL} Complete ==="

echo
