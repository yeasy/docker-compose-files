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

echo_b "=== Fetching blocks ==="

channelFetchAll ${APP_CHANNEL} $org $peer

channelFetchAll ${SYS_CHANNEL} $org $peer

echo_g "Block fetching done!"
