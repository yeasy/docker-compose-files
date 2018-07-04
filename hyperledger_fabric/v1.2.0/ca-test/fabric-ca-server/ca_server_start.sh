#!/usr/bin/env bash

echo $PWD

if [ ! -d tlsca ]; then
	mkdir tlsca
	echo "Generate the credentials for tlsca"
	fabric-ca-server init --csr.cn=tlsca.org1.example.com
	mv ca-cert.pem tlsca/tls-cert.pem
	mv msp/keystore/*_sk tlsca/
fi

if [ ! -d ca ]; then
mkdir ca
	echo "Generate the credentials for ca"
	fabric-ca-server init --csr.cn=ca.org1.example.com
	cp ca-cert.pem ca/ca-cert.pem
	cp msp/keystore/*_sk ca/
fi

fabric-ca-server start \
	--tls.enabled=false \
	--tls.certfile tlsca/tls-cert.pem \
	-b admin:adminpw