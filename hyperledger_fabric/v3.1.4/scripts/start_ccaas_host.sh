#!/bin/bash

set -euo pipefail

CC_NAME=${1:?missing chaincode name}
PACKAGE_FILE=${2:?missing package file}
CC_SERVER_HOST=${3:?missing chaincode service host}
CC_SERVER_PORT=${4:?missing chaincode service port}

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
PACKAGE_BASENAME=$(basename "${PACKAGE_FILE}")
CONTAINER_PACKAGE="/tmp/scripts/${PACKAGE_BASENAME}"
ENV_FILE="${ROOT_DIR}/scripts/${CC_NAME}-ccaas.env"

package_id=$(docker exec fabric-cli bash -lc "peer lifecycle chaincode calculatepackageid '${CONTAINER_PACKAGE}'" | tr -d '\r')
[ -n "${package_id}" ] || {
  echo "failed to calculate package id for ${CC_NAME}" >&2
  exit 1
}

cat >"${ENV_FILE}" <<EOF
CHAINCODE_ID=${package_id}
CHAINCODE_SERVER_ADDRESS=0.0.0.0:${CC_SERVER_PORT}
EOF

env -u DOCKER_DEFAULT_PLATFORM \
  DOCKER_BUILDKIT=0 \
  COMPOSE_DOCKER_CLI_BUILD=0 \
  docker-compose -f "${ROOT_DIR}/docker-compose-ccaas.yaml" build --pull --no-cache "${CC_SERVER_HOST}"

docker rm -f "${CC_SERVER_HOST}" >/dev/null 2>&1 || true

env -u DOCKER_DEFAULT_PLATFORM \
  DOCKER_BUILDKIT=0 \
  COMPOSE_DOCKER_CLI_BUILD=0 \
  docker-compose -f "${ROOT_DIR}/docker-compose-ccaas.yaml" rm -fs "${CC_SERVER_HOST}" >/dev/null 2>&1 || true

env -u DOCKER_DEFAULT_PLATFORM \
  DOCKER_BUILDKIT=0 \
  COMPOSE_DOCKER_CLI_BUILD=0 \
  docker-compose -f "${ROOT_DIR}/docker-compose-ccaas.yaml" up -d --force-recreate "${CC_SERVER_HOST}"

for _ in $(seq 1 30); do
  status=$(docker inspect --format '{{.State.Status}}' "${CC_SERVER_HOST}" 2>/dev/null || true)
  if [ "${status}" = "running" ]; then
    exit 0
  fi
  sleep 1
done

docker logs "${CC_SERVER_HOST}" || true
echo "external chaincode service ${CC_SERVER_HOST} failed to start" >&2
exit 1
