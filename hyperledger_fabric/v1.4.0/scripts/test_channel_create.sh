#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Create channel
echo_b "=== Creating channel ${APP_CHANNEL} with ${APP_CHANNEL_TX}... ==="

channelCreate "${APP_CHANNEL}" "${APP_CHANNEL_TX}" 1 0

echo_g "=== Created channel ${APP_CHANNEL} with ${APP_CHANNEL_TX} ==="

echo
