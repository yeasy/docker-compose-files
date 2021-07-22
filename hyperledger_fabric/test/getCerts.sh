#!/bin/bash
# Generate certs from org json file
# It will overwrite any local cert files

# Usage: ./script jsonFile

if [ $# -lt 1 ]; then
    echo "Please use the json file as the argument" && exit 1
fi

file=$1

echo "Output admin cert"
jq -r ".certs.admincert" $file > admin.cert

echo "Output ca cert"
jq -r ".certs.cacert" $file > ca.cert

echo "Output tlsca cert"
jq -r ".certs.tlscacert" $file > tlsca.cert

echo "Output intermediate certs"
jq -r ".certs.intermediatecerts" $file > intermediate.cert

echo "Output adminou cert"
jq -r ".certs.nodeouidentifiercert.adminouidentifiercert" $file > adminou.cert

echo "Output clientou cert"
jq -r ".certs.nodeouidentifiercert.clientouidentifiercert" $file > clientou.cert

echo "Output peerou cert"
jq -r ".certs.nodeouidentifiercert.peerouidentifiercert" $file > peerou.cert

echo "Output ordererou cert"
jq -r ".certs.nodeouidentifiercert.ordererouidentifiercert" $file > ordererou.cert

