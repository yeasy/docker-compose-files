#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

#set -x

## Create channel
echo_b "Creating channel ${CHANNEL_NAME}..."
setEnvs 1 0
channelCreate ${CHANNEL_NAME}

## Join all the peers to the channel
echo_b "Having all peers join the channel ${CHANNEL_NAME}..."
setEnvs 1 0
channelJoin ${CHANNEL_NAME} 0
setEnvs 1 1
channelJoin ${CHANNEL_NAME} 1
setEnvs 2 0
channelJoin ${CHANNEL_NAME} 2
setEnvs 2 1
channelJoin ${CHANNEL_NAME} 3