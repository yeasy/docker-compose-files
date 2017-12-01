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

for i in {0..4}
do
	echo_b "Fetch block $i"
	channelFetch ${CHANNEL_NAME} $org $peer $i
done

echo_g "Block fetching done!"

exit 0

for i in {0..2}
do
	echo_b "Fetch block $i"
	channelFetch ${SYS_CHANNEL} $org $peer $i
done

