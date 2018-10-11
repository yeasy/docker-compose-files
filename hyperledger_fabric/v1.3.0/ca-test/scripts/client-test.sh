#!/usr/bin/env bash

source env.sh

CONFIG_PATH=/etc/hyperledger/fabric-ca-client

RegisterUser() {
  local URL=$1
  local USER_ID=$2
  local ORG=$3
  local NAME=$4
  local PASSWORD=$5
  local TYPE=$6
  local ATTRS=${7}

  local REQUESTER_HOME=${DEFAULT_USER}@${URL}

	# Enroll default user
	if [ ! -d "${REQUESTER_HOME}" ]; then
		EnrollUser ${URL} ${REQUESTER_HOME} ${ORG} ${DEFAULT_USER} ${DEFAULT_PASS}
	fi

  fabric-ca-client register \
    --csr.cn ${USER_ID} \
		--home ${REQUESTER_HOME} \
    --id.name ${NAME} \
    --id.secret ${PASSWORD} \
    --id.type ${TYPE} \
    --id.attrs "${ATTRS}" \
    --id.maxenrollments 1 \
    --url http://${DEFAULT_USER}:${DEFAULT_PASS}@${URL}:7054

  sleep 0.1
}

EnrollUser() {
	local URL=$1
  local USER_ID=$2
  local ORG=$3
  local USER=$4
  local PASS=$5
  local MSP_PATH=msp

  [ -d ${MSP_PATH} ] || mkdir -p ${MSP_PATH}

  fabric-ca-client enroll \
  --csr.cn ${USER_ID} \
  --csr.names C=US,ST="California",L="San Francisco",O=${ORG} \
  --home ${USER_ID} \
  --mspdir ${MSP_PATH} \
	--url http://${USER}:${PASS}@${URL}:7054
}

EnrollCA() {
	local URL=$1
  local USER_ID=$2
  local ORG=$3
  local USER=$4
  local PASS=$5
  local MSP_PATH=msp

  [ -d ${MSP_PATH} ] || mkdir -p ${MSP_PATH}

  fabric-ca-client enroll \
  --csr.cn ${USER_ID} \
  --csr.names C=US,ST="California",L="San Francisco",O=${ORG} \
  --home ${USER_ID} \
  --mspdir ${MSP_PATH} \
	--url http://${USER}:${PASS}@${URL}
}

EnrollTLSCA() {
	local URL=$1
  local USER_ID=$2
  local ORG=$3
  local USER=$4
  local PASS=$5
  local MSP_PATH=tls

  [ -d ${MSP_PATH} ] || mkdir -p ${MSP_PATH}

  fabric-ca-client enroll \
  --enrollment.profile tls \
  --csr.cn ${USER_ID} \
  --csr.hosts ${USER_ID}
  --csr.names C=US,ST="California",L="San Francisco",O=${ORG} \
  --home ${USER_ID} \
  --mspdir ${MSP_PATH} \
	--url http://${USER}:${PASS}@${URL}:7054

	mv $MSP_PATH/cacerts/*.pem $MSP_PATH/cacerts/${URL}-cert.pem
	mv $MSP_PATH/signcerts/*.pem $MSP_PATH/signcerts/${USER_ID}-cert.pem

	if [ ${MSP_PATH} == "tls" ]; then
		cp $MSP_PATH/signcerts/*.pem $MSP_PATH
		cp $MSP_PATH/keystore/*_sk $MSP_PATH
	fi
}

# cp -rp ${CONFIG_PATH}/msp/signcerts ${CONFIG_PATH}/msp/admincerts

echo "=== Register User ==="
#set -x
#RegisterUser User1@${ORG} user org Admin@org1.example.com

# Generate cert under org
GetCert() {
	local org=$1
	local cn=$1
	echo "=== Enroll Admin ==="
}


ORGS=(org1.example.com org2.example.com )
PEERS=( peer0 peer1 )
ORDERERS=( orderer )
USERS=( Admin User1 )

# Generates peer orgs
for org in "${ORGS[@]}"
do
	cd ${CONFIG_PATH}/peerOrganizations/${org}/

	mkdir peers users

	cd users
	# Register all users at ca and tlsca
	for user in "${USERS[@]}"
	do
		if [ "${user}" == "Admin" ]; then
			RegisterUser ca.${org} ${user}@${org} ${org} ${user} ${user} "user" "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert"
			RegisterUser tlsca.${org} ${user}@${org} ${org} ${user} ${user} "user" "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert"
		else
			RegisterUser ca.${org} ${user}@${org} ${org} ${user} ${user} "user" "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=false:ecert,abac.init=true:ecert"
			RegisterUser tlsca.${org} ${user}@${org} ${org} ${user} ${user} "user" "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=false:ecert,abac.init=true:ecert"
		fi
	done

	cd ../peers
	# Register all peers at ca and tlsca
	for peer in "${PEERS[@]}"
	do
			RegisterUser ca.${org} ${peer}@${org} ${org} ${peer} ${peer} "peer" "hf.Registrar.Roles=peer,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=false:ecert,abac.init=true:ecert"
			RegisterUser tlsca.${org} ${user}@${org} ${org} ${user} ${user} "user" "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=false:ecert,abac.init=true:ecert"
	done

	exit 0


	# Enroll all users
	cp ../tlsca/*.pem Admin@${org}/tls/ca.crt

	EnrollCA ca.${org} Admin@${org} ${org}  adminpw
	EnrollTLSCA tlsca.${org} Admin@${org} ${org} admin adminpw


	# Register all peers
	cd peers
	for peer in "${PEERS[@]}"
	do
		mkdir -p ${peer}.${org}/msp
		mkdir -p ${peer}.${org}/tls
		cp tlsca/*.pem ${peer}.${org}/tls/ca.crt
		GetCerts ${org} ${peer}
	done
	cd ../users
done
