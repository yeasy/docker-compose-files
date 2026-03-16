#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."
source scripts/variables.sh

block_path="raft/channel-artifacts/${APP_CHANNEL_BLOCK}"
[ -f "${block_path}" ] || {
  echo "Missing channel block: ${block_path}"
  exit 1
}

python3 scripts/channel_participation.py join \
  --channel "${APP_CHANNEL}" \
  --block "${block_path}" \
  --orderer "${ORDERER0_ADMIN_URL}" \
  --orderer "${ORDERER1_ADMIN_URL}" \
  --orderer "${ORDERER2_ADMIN_URL}"
