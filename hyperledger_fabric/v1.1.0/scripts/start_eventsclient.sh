#!/usr/bin/env bash

# This script will start the eventsclient

# Importing useful functions
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_g "=== Testing eventsclient in a loop ==="

set -x

CORE_PEER_LOCALMSPID=${ORG1MSP} \
CORE_PEER_MSPCONFIGPATH=${ORG1_ADMIN_MSP} \
eventsclient \
    -server=${ORG1_PEER0_URL} \
    -channelID=${APP_CHANNEL} \
    -filtered=true \
    -tls=true \
    -clientKey=${ORG1_ADMIN_TLS_CLIENT_KEY} \
    -clientCert=${ORG1_ADMIN_TLS_CLIENT_CERT} \
    -rootCert=${ORG1_ADMIN_TLS_CA_CERT}

