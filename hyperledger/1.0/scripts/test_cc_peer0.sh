#!/bin/bash

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "Channel name : "$CHANNEL_NAME

echo_b "====================1.Create channel(default newchannel) ============================="
createChannel

echo_b "====================2.Join pee0 to the channel ======================================"
joinChannel 0

echo_b "====================3.set anchor peers for org1 in the channel==========================="
updateAnchorPeers 0

echo_b "=====================4.Install chaincode test_cc on Peer0/Org0========================"
installChaincode 0

echo_b "=====================5.Instantiate chaincode, this will take a while, pls waiting...==="
instantiateChaincode 0

echo_b "====================6.Query the existing value of a===================================="
chaincodeQuery 0 100

echo_b "=====================7.Invoke a transaction to transfer 10 from a to b=================="
chaincodeInvoke 0

echo_b "=====================8.Check if the result of a is 90==================================="
chaincodeQuery 0 90

echo
echo_g "=====================9.All GOOD, MVE Test completed ===================== "
echo
exit 0
