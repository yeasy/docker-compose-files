#!/usr/bin/env bash

# This script will fetch blocks for testing.

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

org=1
peer=0

echo_b "=== Fetching blocks of channel ${APP_CHANNEL} and ${SYS_CHANNEL} ==="

channelFetchAll ${APP_CHANNEL} $org $peer

channelFetchAll ${SYS_CHANNEL} $org $peer

echo_g "=== Fetched Blocks from channels done! ==="

echo
