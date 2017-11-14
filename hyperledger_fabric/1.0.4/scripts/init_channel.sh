#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Create channel
echo_b "Creating channel ${CHANNEL_NAME}..."
channelCreate ${CHANNEL_NAME}

## Join all the peers to the channel
echo_b "Having all peers join the channel ${CHANNEL_NAME}..."
channelJoin ${CHANNEL_NAME} 0 1 2 3