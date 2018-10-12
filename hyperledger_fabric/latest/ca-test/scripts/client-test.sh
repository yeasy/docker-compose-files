#!/usr/bin/env bash

source env.sh

CONFIG_PATH=/etc/hyperledger/fabric-ca-client

# RegisterUser CA_URL CERT_CN CERT_O USER_NAME USER_PASS TYPE ATTRS
# RegisterUser will register a user to ca with USER_NAME:USER_PASS, TYPE, ATTRS
RegisterUser() {
    local CA_URL=$1
    local CERT_CN=$2
    local CERT_O=$3
    local USER_NAME=$4
    local USER_PASS=$5
    local TYPE=$6
    local ATTRS=${7}

    # Use the default user as requester
    local REQUESTER_HOME=${DEFAULT_USER}@${CA_URL}
    EnrollDefaultUser ${CA_URL} ${CERT_CN} ${CERT_O} ${REQUESTER_HOME}

	# register with the identity of the requester
    fabric-ca-client register \
    --home ${REQUESTER_HOME} \
    --csr.cn "${CERT_CN}" \
    --csr.hosts "${CERT_CN}" \
    --csr.names C=US,ST="California",L="San Francisco",O=${CERT_O} \
    --id.name ${USER_NAME} \
    --id.secret ${USER_PASS} \
    --id.type ${TYPE} \
    --id.attrs "${ATTRS}" \
    --id.maxenrollments -1 \
    --url http://${DEFAULT_USER}:${DEFAULT_PASS}@${CA_URL}:7054

    sleep 0.1
}

# EnrollDefaultUser CA_URL CERT_CN CERT_O HOME_PATH
# EnrollDefaultUser will store credentials to local HOME_PATH/
EnrollDefaultUser() {
    if [ "$#" -ne 4 ]; then
        echo "Illegal number of parameters"
        exit 1
    fi

    local CA_URL=$1
    local CERT_CN=$2
    local CERT_O=$3
    local HOME_PATH=$4

    EnrollUser ${CA_URL} ${CERT_CN} ${CERT_O} ${DEFAULT_USER} ${DEFAULT_PASS} ${HOME_PATH}
}

# EnrollUser CA_URL CERT_CN CERT_O USER PASS HOME_PATH
# EnrollUser will store credentials to local  HOME_PATH/
EnrollUser() {
    if [ "$#" -ne 6 ]; then
        echo "Illegal number of parameters"
        exit 1
    fi
    local CA_URL=$1
    local CERT_CN=$2
    local CERT_O=$3
    local USER=$4
    local PASS=$5
    local HOME_PATH=$6

    if [ -d "${HOME_PATH}" ]; then
        echo "${HOME_PATH} already exists, ignore re-enrolling $@"
        return
    fi
    fabric-ca-client enroll \
		--home ${HOME_PATH} \
		--csr.cn "${CERT_CN}" \
		--csr.hosts "${CERT_CN}" \
		--csr.names C=US,ST="California",L="San Francisco",O=${CERT_O} \
		--url http://${USER}:${PASS}@${CA_URL}:7054
    set +x
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

ORDERER_ORGS=( example.com )
ORDERERS=( orderer0 orderer1 )

PEER_ORGS=( org1.example.com org2.example.com )
PEERS=( peer0 peer1 )

USERS=( Admin User1 )

# TODO: Fabric-ca's existing param support is bad, which reads user.name as csr.cn, and ignore the true csr.cn when do enroll.
# Generates peer orgs
for org in "${PEER_ORGS[@]}"
do
    cd ${CONFIG_PATH}/peerOrganizations/${org}/

    echo "Register all users at ca and tlsca"
    for user in "${USERS[@]}"
    do
        if [ "${user}" == "Admin" ]; then
            RegisterUser ca.${org} "${user}@${org}" ${org} ${user}@${org} ${user} "user" "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert"
            RegisterUser tlsca.${org} "${user}@${org}" ${org} ${user}@${org} ${user} "user" "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert"
        else
            RegisterUser ca.${org} "${user}@${org}" ${org} ${user}@${org} ${user} "user" "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=false:ecert,abac.init=true:ecert"
            RegisterUser tlsca.${org} "${user}@${org}" ${org} ${user}@${org} ${user} "user" "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=false:ecert,abac.init=true:ecert"
        fi
    done

	echo "Enroll all users"
	for user in "${USERS[@]}"
    do
	    EnrollUser ca.${org} "${user}@${org}" ${org} "${user}@${org}" ${user} "${user}@ca.${org}"
        EnrollUser tlsca.${org} "${user}@${org}" ${org} "${user}@${org}" ${user} "${user}@tlsca.${org}"
    done

    echo "Register all peers at ca and tlsca"
    for peer in "${PEERS[@]}"
    do
        RegisterUser ca.${org} ${peer}@${org} ${org} ${peer}@${org} ${peer} "peer" "hf.Registrar.Roles=peer,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=false:ecert,abac.init=true:ecert"
        RegisterUser tlsca.${org} ${peer}@${org} ${org} ${peer}@${org} ${peer} "peer" "hf.Registrar.Roles=peer,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=false:ecert,abac.init=true:ecert"
    done


    echo "Enroll all peers"
    for peer in "${PEERS[@]}"
    do
        EnrollUser ca.${org} ${peer}@${org} ${org} ${peer}@${org} ${peer} ${peer}@ca.${org}
        EnrollUser tlsca.${org} ${peer}@${org} ${org} ${peer}@${org} ${peer} ${peer}@tlsca.${org}
    done
done

exit 0
# Enroll all users
cp ../tlsca/*.pem Admin@${org}/tls/ca.crt

EnrollCA ca.${org} Admin@${org} ${org} adminpw
EnrollTLSCA tlsca.${org} Admin@${org} ${org} admin adminpw

