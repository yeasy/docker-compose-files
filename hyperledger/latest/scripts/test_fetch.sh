#!/usr/bin/env bash

# This script will fetch blocks for testing.

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "Channel name: $CHANNEL_NAME"

echo_b "====================Fetching blocks================================"

echo_b "Fetch block 0"
channelFetch 0 0

echo_b "Fetch block 1"
channelFetch 0 1

echo_b "Fetch block 2"
channelFetch 0 2

echo_b "Fetch block 3"
channelFetch 0 3

echo_g "Block fetching done!"