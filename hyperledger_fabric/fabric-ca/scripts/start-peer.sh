#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
cp /data/fabric-ca-cmd/fabric-ca-client /usr/local/bin
set -e

source $(dirname "$0")/env.sh

awaitSetup

# Although a peer may use the same TLS key and certificate file for both inbound and outbound TLS,
# we generate a different key and certificate for inbound and outbound TLS simply to show that it is permissible

# Generate server TLS cert and key pair for the peer
fabric-ca-client enroll -d --enrollment.profile tls -u $ENROLLMENT_URL -M /tmp/tls --csr.hosts $PEER_HOST
rm -rf $PEER_HOME
# Copy the TLS key and cert to the appropriate place
TLSDIR=$PEER_HOME/tls
mkdir -p $TLSDIR
cp /tmp/tls/signcerts/* $CORE_PEER_TLS_CERT_FILE
cp /tmp/tls/keystore/* $CORE_PEER_TLS_KEY_FILE
DATA_DIR=/${CRYPTO_PEER}/${DOMAIN}/peers/${PEER}.${DOMAIN}
DATA_TLSDIR=/${DATA_DIR}/tls
mkdir -p ${DATA_TLSDIR}
cp $CORE_PEER_TLS_KEY_FILE ${DATA_TLSDIR}/server.key
cp $CORE_PEER_TLS_CERT_FILE ${DATA_TLSDIR}/server.crt
cp $FABRIC_CA_CLIENT_TLS_CERTFILES ${DATA_TLSDIR}/ca.crt
rm -rf /tmp/tls

# Enroll the peer to get an enrollment certificate and set up the core's local MSP directory

mkdir -p ${CORE_PEER_MSPCONFIGPATH}

fabric-ca-client enroll -d -u $ENROLLMENT_URL -M $CORE_PEER_MSPCONFIGPATH
mv ${CORE_PEER_MSPCONFIGPATH}/cacerts/* ${CORE_PEER_MSPCONFIGPATH}/cacerts/ca.${DOMAIN}-cert.pem #rename cacert
#mv ${CORE_PEER_MSPCONFIGPATH}/signcerts/* ${CORE_PEER_MSPCONFIGPATH}/signcerts/${PEER}.${DOMAIN}-cert.pem #rename signcert

finishMSPSetup $CORE_PEER_MSPCONFIGPATH

ORG_ADMIN_CERT=/${CRYPTO_PEER}/${DOMAIN}/msp/admincerts/Admin@${DOMAIN}-cert.pem
copyAdminCert $CORE_PEER_MSPCONFIGPATH

cp -r ${CORE_PEER_MSPCONFIGPATH} ${DATA_DIR}

# Start the peer
log "Starting peer '$CORE_PEER_ID' with MSP at '$CORE_PEER_MSPCONFIGPATH'"
env | grep CORE
peer node start