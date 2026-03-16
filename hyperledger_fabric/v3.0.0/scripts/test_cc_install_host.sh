#!/bin/bash

set -euo pipefail

if [ -f ./func.sh ]; then
  source ./func.sh
elif [ -f scripts/func.sh ]; then
  source scripts/func.sh
fi

CC_NAME=${CC_NAME:-$CC_02_NAME}
CC_PATH=${CC_PATH:-$CC_02_PATH}
HOST_CC_PACKAGE=${CC_PACKAGE:-${PWD}/scripts/${CC_NAME}.tar.gz}
CONTAINER_CC_PACKAGE="/tmp/scripts/${CC_NAME}.tar.gz"
CC_SERVER_HOST=${CC_SERVER_HOST:-$CC_02_SERVER_HOST}
CC_SERVER_PORT=${CC_SERVER_PORT:-$CC_02_SERVER_PORT}

echo_b "=== Packaging chaincode ${CC_NAME} on host... ==="
python3 scripts/package_chaincode.py \
  --source "${CC_PATH}" \
  --kind ccaas \
  --connection-address "${CC_SERVER_HOST}:${CC_SERVER_PORT}" \
  --label "${CC_NAME}" \
  --output "${HOST_CC_PACKAGE}"

echo_b "=== Starting external chaincode service ${CC_NAME}... ==="
bash scripts/start_ccaas_host.sh \
  "${CC_NAME}" \
  "${HOST_CC_PACKAGE}" \
  "${CC_SERVER_HOST}" \
  "${CC_SERVER_PORT}"

echo_b "=== Installing chaincode ${CC_NAME} on all 4 peers... ==="
for org in "${ORGS[@]}"; do
  for peer in "${PEERS[@]}"; do
    t="\${ORG${org}_PEER${peer}_URL}" && peer_url=$(eval echo $t)
    t="\${ORG${org}_PEER${peer}_TLS_ROOTCERT}" && peer_tls_rootcert=$(eval echo $t)
    docker exec fabric-cli bash -lc "cd /tmp && source scripts/func.sh && chaincodeInstallPackage ${org} ${peer} '${peer_url}' '${peer_tls_rootcert}' '${CONTAINER_CC_PACKAGE}'"
  done
done

echo_g "=== Install chaincode done ==="
