#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

#
# The following variables describe the topology and may be modified to provide
# different organization names or the number of peers in each peer organization.
#

# Name of the docker-compose network
NETWORK=fabric-ca

# Names of the orderer organizations
ORDERER_ORGS="orderer"

# Names of the peer organizations
PEER_ORGS="org1 org2"

# Number of peers in each peer organization
NUM_PEERS=2

#
# The remainder of this file contains variables which typically would not be changed.
#

# All org names
ORGS="$ORDERER_ORGS $PEER_ORGS"

# Set to true to populate the "admincerts" folder of MSPs
ADMINCERTS=true

# Number of orderer nodes
NUM_ORDERERS=1

# The volume mount to share data between containers
#DATA=data/${COMPOSE_PROJECT_NAME}
DATA=data
CRYPTO=${DATA}/crypto-config
CRYPTO_ORDERER=${CRYPTO}/ordererOrganizations
CRYPTO_PEER=${CRYPTO}/peerOrganizations

# The path to the genesis block
GENESIS_BLOCK_FILE=/$DATA/genesis.block

# The path to a channel transaction
CHANNEL_TX_FILE=/$DATA/channel.tx

# Name of test channel
CHANNEL_NAME=mychannel

# Query timeout in seconds
QUERY_TIMEOUT=15

# Setup timeout in seconds (for setup container to complete)
SETUP_TIMEOUT=120

# Log directory
LOGDIR=$DATA/logs
LOGPATH=/$LOGDIR

# Name of a the file to create when setup is successful
SETUP_SUCCESS_FILE=${LOGDIR}/setup.successful
# The setup container's log file
SETUP_LOGFILE=${LOGDIR}/setup.log

# The run container's log file
RUN_LOGFILE=${LOGDIR}/run.log
# The run container's summary log file
RUN_SUMFILE=${LOGDIR}/run.sum
RUN_SUMPATH=/${RUN_SUMFILE}
# Run success and failure files
RUN_SUCCESS_FILE=${LOGDIR}/run.success
RUN_FAIL_FILE=${LOGDIR}/run.fail

# Affiliation is not used to limit users in this sample, so just put
# all identities in the same affiliation.
export FABRIC_CA_CLIENT_ID_AFFILIATION=org1

# Set to true to enable use of intermediate CAs
USE_INTERMEDIATE_CA=false


# Config block file path
CONFIG_BLOCK_FILE=/tmp/config_block.pb

# Update config block payload file path
CONFIG_UPDATE_ENVELOPE_FILE=/tmp/config_update_as_envelope.pb


function initOrdererOrgVars {
   if [ $# -ne 1 ]; then
      echo "Usage: initOrdererOrgVars <ORG>"
      exit 1
   fi
   ORG=$1
   ORG_CONTAINER_NAME=${ORG//./-}
   DOMAIN=example.com
   ROOT_CA_HOST=ca.${DOMAIN}
   ROOT_CA_NAME=ca.${DOMAIN}
   ROOT_CA_LOGFILE=$LOGDIR/${ROOT_CA_NAME}.log

   # Root CA admin identity
   ROOT_CA_ADMIN_USER=admin
   ROOT_CA_ADMIN_PASS=${ROOT_CA_ADMIN_USER}pw
   ROOT_CA_ADMIN_USER_PASS=${ROOT_CA_ADMIN_USER}:${ROOT_CA_ADMIN_PASS}

   # Admin identity for the org
   ADMIN_NAME=admin-${ORG}
   ADMIN_PASS=${ADMIN_NAME}pw
   # Typical user identity for the org
   USER_NAME=user-${ORG}
   USER_PASS=${USER_NAME}pw


   ORG_DIR=${CRYPTO_ORDERER}/${DOMAIN}
   ROOT_CA_CERTFILE=/${ORG_DIR}/ca/${ROOT_CA_HOST}-cert.pem
   ANCHOR_TX_FILE=/${ORG_DIR}/anchors.tx
   ORG_MSP_ID=${ORG}MSP
   ORG_MSP_DIR=/${ORG_DIR}/msp
   ORG_ADMIN_CERT_FILENAME=Admin@${DOMAIN}-cert.pem
   ORG_ADMIN_CERT=${ORG_MSP_DIR}/admincerts/${ORG_ADMIN_CERT_FILENAME}
   ORG_ADMIN_HOME=/${ORG_DIR}/users/Admin@${DOMAIN}

   CA_NAME=$ROOT_CA_NAME
   CA_HOST=$ROOT_CA_HOST
   TLSCA_HOST=tls${CA_HOST}
   CA_CHAINFILE=$ROOT_CA_CERTFILE
   CA_ADMIN_USER_PASS=$ROOT_CA_ADMIN_USER_PASS
   CA_LOGFILE=$ROOT_CA_LOGFILE

   #ORDERER_ADMIN_CERT=${ORG_MSP_DIR}/admincerts/Admin@example.com-cert.pem
   #ORDERER_ADMIN_CERT_FILE=Admin@example.com-cert.pem

}



function initPeerOrgVars {
   if [ $# -ne 1 ]; then
      echo "Usage: initPeerOrgVars <ORG>"
      exit 1
   fi
   ORG=$1
   ORG_CONTAINER_NAME=${ORG//./-}
   DOMAIN=${ORG}.example.com

   ROOT_CA_HOST=ca.${DOMAIN}
   ROOT_CA_NAME=ca.${DOMAIN}
   ROOT_CA_LOGFILE=$LOGDIR/${ROOT_CA_NAME}.log

   # Root CA admin identity
   ROOT_CA_ADMIN_USER=admin
   ROOT_CA_ADMIN_PASS=${ROOT_CA_ADMIN_USER}pw
   ROOT_CA_ADMIN_USER_PASS=${ROOT_CA_ADMIN_USER}:${ROOT_CA_ADMIN_PASS}

   # Admin identity for the org
   ADMIN_NAME=admin-${ORG}
   ADMIN_PASS=${ADMIN_NAME}pw
   # Typical user identity for the org
   USER_NAME=user-${ORG}
   USER_PASS=${USER_NAME}pw

   ORG_DIR=${CRYPTO_PEER}/${DOMAIN}
   ROOT_CA_CERTFILE=/${ORG_DIR}/ca/${ROOT_CA_HOST}-cert.pem
   ANCHOR_TX_FILE=/${ORG_DIR}/anchors.tx
   ORG_MSP_ID=${ORG}MSP
   ORG_MSP_DIR=/${ORG_DIR}/msp
   ORG_ADMIN_CERT_FILENAME=Admin@${DOMAIN}-cert.pem
   ORG_ADMIN_CERT=${ORG_MSP_DIR}/admincerts/${ORG_ADMIN_CERT_FILENAME}
   ORG_ADMIN_HOME=/${ORG_DIR}/users/Admin@${DOMAIN}

   ORG_USER1_CERT_FILENAME=USER1@${DOMAIN}-cert.pem
   ORG_USER1_HOME=/${ORG_DIR}/users/USER1@${DOMAIN}
   ORG_USER1_CERT_FILENAME=USER1@${DOMAIN}-cert.pem

   CA_NAME=$ROOT_CA_NAME
   CA_HOST=$ROOT_CA_HOST
   TLSCA_HOST=tls${CA_HOST}
   CA_CHAINFILE=$ROOT_CA_CERTFILE
   CA_ADMIN_USER_PASS=$ROOT_CA_ADMIN_USER_PASS
   CA_LOGFILE=$ROOT_CA_LOGFILE

}


function initOrdererVars {
   if [ $# -ne 1 ]; then
      echo "Usage: initOrdererVars <ORG>"
      exit 1
   fi
   initOrdererOrgVars $1
   DOMAIN=example.com
   ORDERER_HOST=${ORG}.${DOMAIN}
   ORDERER_NAME=${ORG}.${DOMAIN}
   ORDERER_PASS=${ORDERER_NAME}pw
   ORDERER_NAME_PASS=${ORDERER_NAME}:${ORDERER_PASS}
   ORDERER_LOGFILE=$LOGDIR/${ORDERER_NAME}.log
   MYHOME=/var/hyperledger/orderer

   export FABRIC_CA_CLIENT=$MYHOME
   export ORDERER_GENERAL_LOGLEVEL=debug
   export ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
   export ORDERER_GENERAL_GENESISMETHOD=file
   export ORDERER_GENERAL_GENESISFILE=$GENESIS_BLOCK_FILE
   export ORDERER_GENERAL_LOCALMSPID=$ORG_MSP_ID
   export ORDERER_GENERAL_LOCALMSPDIR=$MYHOME/msp
   # enabled TLS
   export ORDERER_GENERAL_TLS_ENABLED=true
   TLSDIR=$MYHOME/tls
   export ORDERER_GENERAL_TLS_PRIVATEKEY=$TLSDIR/server.key
   export ORDERER_GENERAL_TLS_CERTIFICATE=$TLSDIR/server.crt
   export ORDERER_GENERAL_TLS_ROOTCAS=[$CA_CHAINFILE]
}


# initPeerVars <ORG> <NUM>
function initPeerVars {
   if [ $# -ne 2 ]; then
      echo "Usage: initPeerVars <ORG> <NUM>: $*"
      exit 1
   fi
   initPeerOrgVars $1
   NUM=$2

   PEER_HOST=peer${NUM}.${DOMAIN}
   PEER_NAME=peer${NUM}.${DOMAIN}
   PEER_PASS=${PEER_NAME}pw
   PEER_NAME_PASS=${PEER_NAME}:${PEER_PASS}
   PEER_LOGFILE=$LOGDIR/${PEER_NAME}.log
   MYHOME=/etc/hyperledger/fabric
   TLSDIR=$MYHOME/tls

   export FABRIC_CA_CLIENT=$MYHOME
   export CORE_PEER_ID=$PEER_HOST
   export CORE_PEER_ADDRESS=$PEER_HOST:7051
   export CORE_PEER_LOCALMSPID=$ORG_MSP_ID
   export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
   # the following setting starts chaincode containers on the same
   # bridge network as the peers
   # https://docs.docker.com/compose/networking/
   #export CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${COMPOSE_PROJECT_NAME}_${NETWORK}
   export CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=net_${NETWORK}
   # export CORE_LOGGING_LEVEL=ERROR
   export CORE_LOGGING_LEVEL=DEBUG
   export CORE_PEER_TLS_ENABLED=true
   export CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
   export CORE_PEER_TLS_ROOTCERT_FILE=$CA_CHAINFILE
   export CORE_PEER_TLS_CLIENTCERT_FILE=/$ORG_DIR/peers/$PEER_NAME/tls/server.crt
   export CORE_PEER_TLS_CLIENTKEY_FILE=/$ORG_DIR/peers/$PEER_NAME/tls/server.key
   export CORE_PEER_PROFILE_ENABLED=true
   # gossip variables
   export CORE_PEER_GOSSIP_USELEADERELECTION=true
   export CORE_PEER_GOSSIP_ORGLEADER=false
   export CORE_PEER_GOSSIP_EXTERNALENDPOINT=$PEER_HOST:7051
   if [ $NUM -gt 1 ]; then
      # Point the non-anchor peers to the anchor peer, which is always the 1st peer
      export CORE_PEER_GOSSIP_BOOTSTRAP=peer0.${ORG}.example.com:7051
   fi
   export ORDERER_CONN_ARGS="$ORDERER_PORT_ARGS --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE"
}

function genClientTLSCert {
   if [ $# -ne 3 ]; then
      echo "Usage: genClientTLSCert <host name> <cert file> <key file>: $*"
      exit 1
   fi

   HOST_NAME=$1
   CERT_FILE=$2
   KEY_FILE=$3

   # Get a client cert
   fabric-ca-client enroll -d --enrollment.profile tls -u $ENROLLMENT_URL -M /tmp/tls --csr.hosts $HOST_NAME

   mkdir /$DATA/tls || true
   cp /tmp/tls/signcerts/* $CERT_FILE
   cp /tmp/tls/keystore/* $KEY_FILE
   rm -rf /tmp/tls
}

# Switch to the current org's admin identity.  Enroll if not previously enrolled.
function switchToAdminIdentity {
   if [ ! -d $ORG_ADMIN_HOME ]; then
      dowait "$CA_NAME to start" 60 $CA_LOGFILE $CA_CHAINFILE
      log "Enrolling admin '$ADMIN_NAME' with $CA_HOST ..."
      export FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
      export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
      fabric-ca-client enroll -d -u https://$ADMIN_NAME:$ADMIN_PASS@$CA_HOST:7054
      mv $ORG_ADMIN_HOME/msp/cacerts/* $ORG_ADMIN_HOME/msp/cacerts/${CA_HOST}-cert.pem #rename cacert
      mv $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_HOME/msp/signcerts/$ORG_ADMIN_CERT_FILENAME #rename signcert
      # If admincerts are required in the MSP, copy the cert there now and to my local MSP also
      if [ $ADMINCERTS ]; then
         mkdir -p $(dirname "${ORG_ADMIN_CERT}")

         cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_CERT #ORG_MSP_DIR/admincerts
         mkdir $ORG_ADMIN_HOME/msp/admincerts
         cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_HOME/msp/admincerts
      fi
      finishMSPSetup $ORG_ADMIN_HOME/msp

   fi
   export CORE_PEER_MSPCONFIGPATH=$ORG_ADMIN_HOME/msp
}

# Switch to the current org's user identity.  Enroll if not previously enrolled.
function switchToUserIdentity {
   export FABRIC_CA_CLIENT_HOME=$ORG_USER1_HOME
   export CORE_PEER_MSPCONFIGPATH=$FABRIC_CA_CLIENT_HOME/msp
   if [ ! -d $FABRIC_CA_CLIENT_HOME ]; then
      dowait "$CA_NAME to start" 60 $CA_LOGFILE $CA_CHAINFILE
      log "Enrolling user for organization $ORG with home directory $FABRIC_CA_CLIENT_HOME ..."
      export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
      fabric-ca-client enroll -d -u https://$USER_NAME:$USER_PASS@$CA_HOST:7054
      mv $CORE_PEER_MSPCONFIGPATH/cacerts/* $CORE_PEER_MSPCONFIGPATH/cacerts/${CA_HOST}-cert.pem #rename cacert
      mv $CORE_PEER_MSPCONFIGPATH/signcerts/* $CORE_PEER_MSPCONFIGPATH/signcerts/$ORG_USER1_CERT_FILENAME #rename signcert
      # Set up admincerts directory if required
      if [ $ADMINCERTS ]; then
         ACDIR=$CORE_PEER_MSPCONFIGPATH/admincerts
         mkdir -p $ACDIR
         cp $ORG_ADMIN_HOME/msp/signcerts/* $ACDIR
      fi
      #mkdir -p /${DATA}/orgs/$ORG/user
      #cp -r $CORE_PEER_MSPCONFIGPATH /${DATA}/orgs/$ORG/user
   fi
}

# Revokes the fabric user
function revokeFabricUserAndGenerateCRL {
   switchToAdminIdentity
   export  FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
   logr "Revoking the user '$USER_NAME' of the organization '$ORG' with Fabric CA Client home directory set to $FABRIC_CA_CLIENT_HOME and generating CRL ..."
   export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
   fabric-ca-client revoke -d --revoke.name $USER_NAME --gencrl
}

# Generates a CRL that contains serial numbers of all revoked enrollment certificates.
# The generated CRL is placed in the crls folder of the admin's MSP
function generateCRL {
   switchToAdminIdentity
   export FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
   logr "Generating CRL for the organization '$ORG' with Fabric CA Client home directory set to $FABRIC_CA_CLIENT_HOME ..."
   export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
   fabric-ca-client gencrl -d
}

# Copy the org's admin cert into some target MSP directory
# This is only required if ADMINCERTS is enabled.
function copyAdminCert {
   if [ $# -ne 1 ]; then
      fatal "Usage: copyAdminCert <targetMSPDIR>"
   fi
   if $ADMINCERTS; then
      dstDir=$1/admincerts
      mkdir -p $dstDir
      dowait "$ORG administator to enroll" 60 $SETUP_LOGFILE $ORG_ADMIN_CERT
      cp $ORG_ADMIN_CERT $dstDir
   fi
}

# Create the TLS directories of the MSP folder if they don't exist.
# The fabric-ca-client should do this.
function finishMSPSetup {
   if [ $# -ne 1 ]; then
      fatal "Usage: finishMSPSetup <targetMSPDIR>"
   fi
   if [ ! -d $1/tlscacerts ]; then
      mkdir $1/tlscacerts
      cp $1/cacerts/* $1/tlscacerts
      #mv $1/tlscacerts/* $1/tlscacerts/${TLSCA_HOST}-cert.pem
   fi
}

function awaitSetup {
   dowait "the 'setup' container to finish registering identities, creating the genesis block and other artifacts" $SETUP_TIMEOUT $SETUP_LOGFILE /$SETUP_SUCCESS_FILE
}

# Wait for one or more files to exist
# Usage: dowait <what> <timeoutInSecs> <errorLogFile> <file> [<file> ...]
function dowait {
   if [ $# -lt 4 ]; then
      fatal "Usage: dowait: $*"
   fi
   local what=$1
   local secs=$2
   local logFile=$3
   shift 3
   local logit=true
   local starttime=$(date +%s)
   for file in $*; do
      until [ -f $file ]; do
         if [ "$logit" = true ]; then
            log -n "Waiting for $what ..."
            logit=false
         fi
         sleep 1
         if [ "$(($(date +%s)-starttime))" -gt "$secs" ]; then
            echo ""
            fatal "Failed waiting for $what ($file not found); see $logFile"
         fi
         echo -n "."
      done
   done
   echo ""
}

# Wait for a process to begin to listen on a particular host and port
# Usage: waitPort <what> <timeoutInSecs> <errorLogFile> <host> <port>
function waitPort {
   set +e
   local what=$1
   local secs=$2
   local logFile=$3
   local host=$4
   local port=$5
   nc -z $host $port > /dev/null 2>&1
   if [ $? -ne 0 ]; then
      log -n "Waiting for $what ..."
      local starttime=$(date +%s)
      while true; do
         sleep 1
         nc -z $host $port > /dev/null 2>&1
         if [ $? -eq 0 ]; then
            break
         fi
         if [ "$(($(date +%s)-starttime))" -gt "$secs" ]; then
            fatal "Failed waiting for $what; see $logFile"
         fi
         echo -n "."
      done
      echo ""
   fi
   set -e
}


# log a message
function log {
   if [ "$1" = "-n" ]; then
      shift
      echo -n "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   else
      echo "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   fi
}

# fatal a message
function fatal {
   log "FATAL: $*"
   exit 1
}
