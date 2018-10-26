#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
cp /data/fabric-ca-cmd/fabric-ca-client /usr/local/bin
source $(dirname "$0")/env.sh

# Wait for setup to complete sucessfully
awaitSetup
set -e


# Enroll to get orderer's TLS cert (using the "tls" profile)
fabric-ca-client enroll -d --enrollment.profile tls -u $ENROLLMENT_URL -M /tmp/tls --csr.hosts $ORDERER_HOST

# Copy the TLS key and cert to the appropriate place
TLSDIR=$ORDERER_HOME/tls
mkdir -p $TLSDIR
cp /tmp/tls/keystore/* $ORDERER_GENERAL_TLS_PRIVATEKEY
cp /tmp/tls/signcerts/* $ORDERER_GENERAL_TLS_CERTIFICATE
DATA_DIR=/${CRYPTO_ORDERER}/${DOMAIN}/orderers/${ORDERER}.${DOMAIN}
DATA_TLSDIR=/${DATA_DIR}/tls
mkdir -p ${DATA_TLSDIR}
cp $ORDERER_GENERAL_TLS_PRIVATEKEY ${DATA_TLSDIR}/server.key
cp $ORDERER_GENERAL_TLS_CERTIFICATE ${DATA_TLSDIR}/server.crt
cp $FABRIC_CA_CLIENT_TLS_CERTFILES ${DATA_TLSDIR}/ca.crt
rm -rf /tmp/tls

# Enroll again to get the orderer's enrollment certificate (default profile)
fabric-ca-client enroll -d -u $ENROLLMENT_URL -M $ORDERER_GENERAL_LOCALMSPDIR
mv $ORDERER_GENERAL_LOCALMSPDIR/cacerts/* $ORDERER_GENERAL_LOCALMSPDIR/cacerts/ca.${DOMAIN}-cert.pem #rename cacert
#v $ORDERER_GENERAL_LOCALMSPDIR/signcerts/* $ORDERER_GENERAL_LOCALMSPDIR/signcerts/${ORDERER}.${DOMAIN}-cert.pem #rename signcert

# Finish setting up the local MSP for the orderer
finishMSPSetup $ORDERER_GENERAL_LOCALMSPDIR

ORG_ADMIN_CERT=/${CRYPTO_ORDERER}/${DOMAIN}/msp/admincerts/Admin@${DOMAIN}-cert.pem
copyAdminCert $ORDERER_GENERAL_LOCALMSPDIR
cp -r $ORDERER_GENERAL_LOCALMSPDIR ${DATA_DIR}


# Wait for the genesis block to be created
dowait "genesis block to be created" 60 $SETUP_LOGFILE $ORDERER_GENERAL_GENESISFILE

# Start the orderer
env | grep ORDERER
orderer
