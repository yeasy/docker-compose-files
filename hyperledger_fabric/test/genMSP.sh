#!/bin/bash
# Generate a valid msp dir based on given certificates.json and admin-credential
# It will overwrite any local msp path with the same name as msp-${mspId}

# Usage: ./script mspId

if [ $# -lt 1 ]; then
    echo "Please use the <msp id> as the argument" && exit 1
fi

mspId=$1
echo "msp id = ${mspId}"

cert_file=${mspId}-certificates.json
admin_dir=${mspId}-admin-credential

mkdir -p "msp-${mspId}"
pushd "msp-${mspId}" && mkdir tlscacerts signcerts keystore cacerts admincerts && popd || exit 1

echo "Unzip ${mspId}-admin-credential.zip file to create the ${admin_dir}"
unzip -d "${mspId}-admin-credential" "${mspId}-admin-credential.zip"

echo "Get tlscacert from ${cert_file}"
jq -r .certs.tlscacert "${cert_file}" > "msp-${mspId}/tlscacerts/tlsca.cert"

echo "Get signcerts from ${admin_dir}"
cp "${admin_dir}/${mspId}-cert.pem" "msp-${mspId}/signcerts/"

echo "Get keystore from ${admin_dir}"
cp "${admin_dir}/${mspId}-key" "msp-${mspId}/keystore/"

echo "Get cacerts from ${cert_file}"
jq -r .certs.cacert "${cert_file}" > "msp-${mspId}/cacerts/ca.cert"

echo "Get admincerts from ${admin_dir}"
cp "${admin_dir}/${mspId}-cert.pem" "msp-${mspId}/admincerts/"
