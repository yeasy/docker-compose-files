#!/bin/bash
# Generate a valid msp dir based on given certificates.json and admin-credential
# It will overwrite any local msp path with the same name as msp-${mspId}

# Usage: ./script mspId

if [ $# -lt 1 ]; then
    echo "Please use the <msp id> as the argument" && exit 1
fi

mspId=$1
mspPath=msp-${mspId}
echo "msp id=${mspId}, msp path=${mspPath}"

certFile=${mspId}-certificates.json
adminCredentialDir=${mspId}-admin-credential
adminCredentialFile=${mspId}-admin-credential.zip

[ -d "${mspPath}" ] && { echo "${mspPath} already exists, will exit" && exit 0; }
mkdir -p "${mspPath}"

pushd "${mspPath}" && mkdir tlscacerts signcerts keystore cacerts admincerts && popd || exit 1

echo "Unzip ${adminCredentialFile} file to create the ${adminCredentialDir}"
unzip -d "${adminCredentialDir}" "${adminCredentialFile}"

echo "Get tlscacert from ${certFile}"
jq -r .certs.tlscacert "${certFile}" > "${mspPath}/tlscacerts/tlsca.cert"

echo "Get signcerts from ${adminCredentialDir}"
cp "${adminCredentialDir}/${mspId}-cert.pem" "${mspPath}/signcerts/"

echo "Get keystore from ${adminCredentialDir}"
cp "${adminCredentialDir}/${mspId}-key" "${mspPath}/keystore/"

echo "Get cacerts from ${certFile}"
jq -r .certs.cacert "${certFile}" > "${mspPath}/cacerts/ca.cert"

echo "Get admincerts from ${adminCredentialDir}"
cp "${adminCredentialDir}/${mspId}-cert.pem" "${mspPath}/admincerts/"

echo "Remove the unzipped ${adminCredentialDir}"
rm -rf ${adminCredentialDir}

echo "MSP is created at ${mspPath}, now you can run: rm -rf ${certFile} ${adminCredentialFile}"
