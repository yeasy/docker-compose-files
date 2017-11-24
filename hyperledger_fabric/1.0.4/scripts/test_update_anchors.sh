#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

#setEnvs 0

## Set the anchor peers for each org in the channel
echo_b "Updating anchor peers for org1..."
setEnvs 1 0
updateAnchorPeers ${CHANNEL_NAME} 0

echo_b "Updating anchor peers for org2..."
setEnvs 2 0
updateAnchorPeers ${CHANNEL_NAME} 2
