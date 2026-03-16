#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
  source ./func.sh
elif [ -f scripts/func.sh ]; then
  source scripts/func.sh
fi

CC_NAME=${CC_NAME:-$CC_02_NAME}
CC_INIT_ARGS=${CC_INIT_ARGS:-$CC_02_INIT_ARGS}

echo_r "Legacy instantiate is not supported for the Fabric 3.1 example."
echo_r "Run test_cc_install, test_cc_approveformyorg, test_cc_commit, then test_cc_invoke_query."
exit 1
