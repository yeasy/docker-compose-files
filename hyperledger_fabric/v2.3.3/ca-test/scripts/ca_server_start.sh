#!/usr/bin/env bash

source env.sh

if [ "$#" -ne 2 ]; then
	echo "Illegal number of parameters"
	exit 1
fi

ORG_NAME=$1  # org1.example.com
TYPE=$2  # ca | tlsca

ORG_PATH=/etc/hyperledger/fabric-ca-server
CA_PATH=${ORG_PATH}/${TYPE}  # e.g., /etc/hyperledger/fabric-ca-server/ca

echo $(hostname)

# do not recreate the credentials if existed
if [ ! -d ${CA_PATH} ]; then
	mkdir -p ${CA_PATH}
	cd ${CA_PATH}
	echo "Generate the credentials for ${TYPE}.${ORG_NAME}"

	# generate fabric-ca-server-config.yaml
	#fabric-ca-server init \
	#	-H ${CA_PATH} \
	#	-b ${DEFAULT_USER}:${DEFAULT_PASS}
	#rm -rf msp/* ca-cert.pem  # these credentials are wrong

	echo "${CA_SERVER_DEFAULT_CONFIG}" >> fabric-ca-server-config.yaml

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
	echo "Generate certificates for ${TYPE}.${ORG_NAME} under ${CA_PATH}"
	fabric-ca-server init -H ${CA_PATH}

	cp msp/keystore/*_sk ${TYPE}.${ORG_NAME}_sk
fi

echo "Start ${TYPE}.${ORG_NAME}..."
fabric-ca-server start -H ${CA_PATH}
