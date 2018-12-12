#!/usr/bin/env bash

# use /tmp/crypto-config.yaml to generate /tmp/crypto-config
# use /tmp/org3/crypto-config.yaml to generate /tmp/org3/crypto-config

cd /tmp  # we use /tmp as the base working path

# The crypto-config will be used by channel artifacts generation later
CRYPTO_CONFIG=crypto-config

echo "Generating crypto-config for org1 and org2..."
ls -l ${CRYPTO_CONFIG}

cryptogen generate \
	--config=crypto-config.yaml \
	--output ${CRYPTO_CONFIG}

if [ $? -ne 0 ]; then
	echo "Failed to generate certificates for org1 and org2..."
	exit 1
fi

echo "Generating crypto-config for org3..."
cryptogen generate \
	--config=org3/crypto-config.yaml \
	--output org3/${CRYPTO_CONFIG}

if [ $? -ne 0 ]; then
	echo_r "Failed to generate certificates for org3..."
	exit 1
fi

echo "Generated credential files and saved to ${CRYPTO_CONFIG}."
