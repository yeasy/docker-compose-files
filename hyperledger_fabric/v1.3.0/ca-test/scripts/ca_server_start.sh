#!/usr/bin/env bash

source env.sh

#TODO: check param number is 2

ORG_NAME=$1  # org1.example.com
TYPE=$2  # ca | tlsca

ORG_PATH=/etc/hyperledger/fabric-ca-server
CA_PATH=${ORG_PATH}/${TYPE}  # e.g., /etc/hyperledger/fabric-ca-server/ca

echo $(hostname)

[ -d ${CA_PATH} ] || mkdir -p ${CA_PATH}

cd ${CA_PATH}

echo $PWD # /etc/hyperledger/fabric-ca-server/ca

echo "Generate the credentials for ${TYPE}.${ORG_NAME}"
#fabric-ca-server init --csr.cn=${ORG_NAME} -b admin:pass
#mv ca-cert.pem ${ORG_NAME}-cert.pem
#mv msp/keystore/*_sk ${ORG_NAME}_sk

# generate fabric-ca-server-config.yaml
fabric-ca-server init \
	-H ${CA_PATH} \
	-b ${DEFAULT_USER}:${DEFAULT_PASS}

rm -rf msp/* ca-cert.pem

# Update config
echo "Update fabric-ca-server-config.yaml"
yq w -i fabric-ca-server-config.yaml ca.name "${TYPE}.${ORG_NAME}"
yq w -i fabric-ca-server-config.yaml ca.certfile "${TYPE}.${ORG_NAME}-cert.pem"
yq w -i fabric-ca-server-config.yaml ca.keyfile "${TYPE}.${ORG_NAME}_sk"

yq w -i fabric-ca-server-config.yaml csr.cn "${TYPE}.${ORG_NAME}"
yq w -i fabric-ca-server-config.yaml csr.names[0].O "${ORG_NAME}"
yq w -i fabric-ca-server-config.yaml csr.names[0].OU "${TYPE}"

yq w -i fabric-ca-server-config.yaml tls.enabled false
#yq w -i fabric-ca-server-config.yaml tls.certfile "${ORG_PATH}/tlsca/tlsca.${ORG_NAME}-cert.pem"
#yq w -i fabric-ca-server-config.yaml tls.keyfile "${ORG_PATH}/tlsca/tlsca.${ORG_NAME}_sk"

# Generate new certs based on updated config
echo "Generate certificates based on config"
fabric-ca-server init -H ${CA_PATH}

cp msp/keystore/*_sk ${TYPE}.${ORG_NAME}_sk

echo "Start ${TYPE}.${ORG_NAME}..."
fabric-ca-server start -H ${CA_PATH}
