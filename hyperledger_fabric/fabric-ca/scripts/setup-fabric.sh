#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

#
# This script does the following:
# 1) registers orderer and peer identities with intermediate fabric-ca-servers
# 2) Builds the channel artifacts (e.g. genesis block, etc)
#

function main {
   log "Beginning building channel artifacts ..."
   registerIdentities
   enrollIdentities
   generateChannelArtifacts
   log "Finished building channel artifacts"
   touch /$SETUP_SUCCESS_FILE
}

# Enroll the CA administrator
function enrollCAAdmin {
   waitPort "$CA_NAME to start" 90 $CA_LOGFILE $CA_HOST 7054
   log "Enrolling with $CA_NAME as bootstrap identity ..."
   export FABRIC_CA_CLIENT_HOME=$HOME/cas/$CA_NAME
   export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
   fabric-ca-client enroll -d -u https://admin:adminpw@$CA_HOST:7054
}

function registerIdentities {
   log "Registering identities ..."
   registerOrdererIdentities
   registerPeerIdentities
}

function enrollIdentities {
   log "Registering identities ..."
   enrollOrdererIdentities
   enrollPeerIdentities
}

# Register any identities associated with the orderer
function registerOrdererIdentities {
   initOrdererOrgVars $ORDERER_ORGS
   enrollCAAdmin
   initOrdererVars $ORDERER_ORGS
   log "Registering $ORDERER_NAME with $CA_NAME"
   fabric-ca-client register -d --id.name $ORDERER_NAME --id.secret $ORDERER_PASS --id.type orderer
   log "Registering admin identity with $CA_NAME"
   # The admin identity has the "admin" attribute which is added to ECert by default
   fabric-ca-client register -d --id.name $ADMIN_NAME --id.secret $ADMIN_PASS --id.attrs "admin=true:ecert"
}

# Register any identities associated with a peer
function registerPeerIdentities {
   for ORG in $PEER_ORGS; do
      initPeerOrgVars $ORG
      enrollCAAdmin
      local COUNT=1
      while [[ "$COUNT" -le $NUM_PEERS ]]; do
         initPeerVars $ORG $((COUNT-1))
         log "Registering $PEER_NAME with $CA_NAME"
         fabric-ca-client register -d --id.name $PEER_NAME --id.secret $PEER_PASS --id.type peer
         COUNT=$((COUNT+1))
      done
      log "Registering admin identity with $CA_NAME"
      # The admin identity has the "admin" attribute which is added to ECert by default
      fabric-ca-client register -d --id.name $ADMIN_NAME --id.secret $ADMIN_PASS --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert"
      log "Registering user identity with $CA_NAME"
      fabric-ca-client register -d --id.name $USER_NAME --id.secret $USER_PASS
   done
}

function enrollOrdererIdentities {
   log "Getting CA certificates ..."
   for ORG in $ORDERER_ORGS; do
      initOrdererOrgVars $ORG
      log "Getting CA certs for organization $ORG and storing in $ORG_MSP_DIR"
      export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
      fabric-ca-client getcacert -d -u https://$CA_HOST:7054 -M $ORG_MSP_DIR
      mv $ORG_MSP_DIR/cacerts/* $ORG_MSP_DIR/cacerts/${CA_HOST}-cert.pem
      finishMSPSetup $ORG_MSP_DIR
      # If ADMINCERTS is true, we need to enroll the admin now to populate the admincerts directory
      if [ $ADMINCERTS ]; then
         switchToAdminIdentity
      fi
   done
}

function enrollPeerIdentities {
   log "Getting CA certificates ..."
   for ORG in $PEER_ORGS; do
      initPeerOrgVars $ORG
      log "Getting CA certs for organization $ORG and storing in $ORG_MSP_DIR"
      export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
      fabric-ca-client getcacert -d -u https://$CA_HOST:7054 -M $ORG_MSP_DIR
      mv $ORG_MSP_DIR/cacerts/* $ORG_MSP_DIR/cacerts/${CA_HOST}-cert.pem
      finishMSPSetup $ORG_MSP_DIR
      # If ADMINCERTS is true, we need to enroll the admin now to populate the admincerts directory
      if [ $ADMINCERTS ]; then
         switchToAdminIdentity
         switchToUserIdentity
      fi
   done
}

# printOrg
function printOrg {
   echo "
  - &$ORG_CONTAINER_NAME

    Name: $ORG

    # ID to load the MSP definition as
    ID: $ORG_MSP_ID

    # MSPDir is the filesystem path which contains the MSP configuration
    MSPDir: $ORG_MSP_DIR"
}

# printOrdererOrg <ORG>
function printOrdererOrg {
   initOrdererOrgVars $1
   printOrg
}

# printPeerOrg <ORG> <COUNT>
function printPeerOrg {
   initPeerVars $1 $2
   printOrg
   echo "
    AnchorPeers:
       # AnchorPeers defines the location of peers which can be used
       # for cross org gossip communication.  Note, this value is only
       # encoded in the genesis block in the Application section context
       - Host: $PEER_HOST
         Port: 7051"
}


function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    fatal "configtxgen tool not found. exiting"
  fi

  log "Generating orderer genesis block at $GENESIS_BLOCK_FILE"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  configtxgen -configPath /data -profile TwoOrgsOrdererGenesis -outputBlock $GENESIS_BLOCK_FILE
  if [ "$?" -ne 0 ]; then
    fatal "Failed to generate orderer genesis block"
  fi

  log "Generating channel configuration transaction at $CHANNEL_TX_FILE"
  configtxgen -configPath /data -profile TwoOrgsChannel -outputCreateChannelTx $CHANNEL_TX_FILE -channelID $CHANNEL_NAME
  if [ "$?" -ne 0 ]; then
    fatal "Failed to generate channel configuration transaction"
  fi

  for ORG in $PEER_ORGS; do
     initPeerOrgVars $ORG
#     org=`echo ${ORG:0:1}|tr '[a-z]' '[A-Z]'`
#     org=${org}${ORG:1}MSP
     log "Generating anchor peer update transaction for $org at $ANCHOR_TX_FILE"
     configtxgen -configPath /data -profile TwoOrgsChannel -outputAnchorPeersUpdate $ANCHOR_TX_FILE \
                 -channelID $CHANNEL_NAME -asOrg $ORG
     if [ "$?" -ne 0 ]; then
        fatal "Failed to generate anchor peer update for $ORG"
     fi
  done

}

cp /data/fabric-ca-cmd/fabric-ca-client /usr/local/bin
set -e

SDIR=$(dirname "$0")
source $SDIR/env.sh

main

while true
do
  sleep 9
done
