#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Set the anchor peers for each org in the channel
echo_b "Updating anchor peers for org1..."
updateAnchorPeers ${APP_CHANNEL} 1 0

echo_b "Updating anchor peers for org2..."
updateAnchorPeers ${APP_CHANNEL} 2 0
