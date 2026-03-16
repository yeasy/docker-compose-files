#!/usr/bin/env bash

# LSCC is intentionally disabled in the Fabric 3.1 example because the
# supported runtime path uses lifecycle commands instead.

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
  source ./func.sh
elif [ -f scripts/func.sh ]; then
  source scripts/func.sh
fi

echo_r "LSCC test is not available for the Fabric 3.1 example."
echo_r "Use lifecycle queries instead: test_cc_queryinstalled, test_cc_queryapproved, test_cc_querycommitted."
exit 1
