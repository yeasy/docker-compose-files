#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Create channel
echo_b "Creating channel ${CHANNEL_NAME}..."
channelCreate ${CHANNEL_NAME} 1 0
