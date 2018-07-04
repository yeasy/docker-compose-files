#!/usr/bin/env bash

FABRIC_CA_SERVER="${FABRIC_CA_SERVER:-$1}"
CONFIG_PATH=/etc/hyperledger/fabric-ca-client


ORG="org1.example.com"

RegisterUser() {
  local USER_ID=$1
  local USER_TYPE=$2
  local USER_AFF=${3}
  local MSP_PATH=$4

  fabric-ca-client register \
    --csr.cn ${USER_ID} \
		--home ${CONFIG_PATH}/${MSP_PATH} \
    --id.affiliation ${USER_AFF} \
    --id.name ${USER_ID} \
    --id.secret password \
    --id.type ${USER_TYPE} \
    --id.maxenrollments 1 \
    --url http://${FABRIC_CA_SERVER}:7054

  sleep 0.5
}

EnrollUser() {
  local USER_ID=$1
  local ORG=$2
  local USER=$3
  local PASS=$4
  local MSP_PATH=$5

  [ -d ${CONFIG_PATH}/${MSP_PATH} ] || mkdir -p ${CONFIG_PATH}/${MSP_PATH}

  fabric-ca-client enroll \
  --csr.cn ${USER_ID} \
  --csr.names C=US,ST="California",L="San Francisco",O=${ORG} \
  --home ${CONFIG_PATH}/${MSP_PATH} \
	--url http://${USER}:${PASS}@${FABRIC_CA_SERVER}:7054
}

echo "=== Enroll Admin ==="
EnrollUser Admin@org1.example.com org1.example.com admin adminpw Admin@org1.example.com

# cp -rp ${CONFIG_PATH}/msp/signcerts ${CONFIG_PATH}/msp/admincerts

echo "=== Register User ==="
set -x
RegisterUser User1@${ORG} user org Admin@org1.example.com


#exit 0
while true; do
	sleep 1
done