#!/usr/bin/env bash

# use /tmp/crypto-config.yaml to generate /tmp/config-config

cd /tmp  # we use /tmp as the base working path

# Define those global variables
if [ -f ./variables.sh ]; then
 source ./variables.sh
elif [ -f scripts/variables.sh ]; then
 source scripts/variables.sh
else
	echo "Cannot find the variables.sh files, pls check"
	exit 1
fi

# The crypto-config will be used by channel artifacts generation later
CRYPTO_CONFIG_PATH=${FABRIC_CFG_PATH}/${CRYPTO_CONFIG}

#if [ -d ${CFG_PATH}/${CRYPTO_CONFIG} ]; then
if [ "$(ls -A ${CRYPTO_CONFIG_PATH})" ]; then
	echo "crypto-config data existed, can clean it by 'make clean_config'"
	exit 0
	# rm -rf ${CRYPTO_CONFIG_PATH}/*
fi

echo "Generating crypto-config for org1 and org2..."

cryptogen generate \
	--config=crypto-config.yaml \
	--output ${CRYPTO_CONFIG_PATH}

if [ $? -ne 0 ]; then
	echo_r "Failed to generate certificates for org1 and org2..."
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

echo "Generated crypto-config and saved to ${CRYPTO_CONFIG_PATH}."
