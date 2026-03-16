#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
  source ./func.sh
elif [ -f scripts/func.sh ]; then
  source scripts/func.sh
fi

CC_NAME=${CC_NAME:-$CC_02_NAME}
CC_PATH=${CC_PATH:-$CC_02_PATH}
CC_UPGRADE_ARGS=${CC_UPGRADE_ARGS:-$CC_02_UPGRADE_ARGS}
CC_QUERY_ARGS=${CC_QUERY_ARGS:-$CC_02_QUERY_ARGS}

echo_r "Legacy chaincode upgrade is not supported for the Fabric 3.0 example."
echo_r "Package and install the new version, then rerun approveformyorg and commit with an updated sequence."
exit 1
