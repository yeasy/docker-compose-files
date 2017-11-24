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

echo_b "Fetch block 0"
channelFetch ${CHANNEL_NAME} $org $peer 0

echo_b "Fetch block 1"
channelFetch ${CHANNEL_NAME} $org $peer 1

echo_b "Fetch block 2"
channelFetch ${CHANNEL_NAME} $org $peer 2

echo_b "Fetch block 3"
channelFetch ${CHANNEL_NAME} $org $peer 3

echo_g "Block fetching done!"