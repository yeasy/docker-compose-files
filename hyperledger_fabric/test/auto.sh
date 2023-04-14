# This should be run in env with fabric command line binaries including peer, configtxlator

# docker run --rm -it --work-dir=/tmp/test -v $PWD/:/tmp/test yeasy/hyperledger-fabric:2.2.4 bash

mspId=sm25foun
channelId=default
#channelId=testchainid
ordererAddr=sm25foun-oabcs1-iad.blockchain.ocp.oraclecloud.com:20003

bash fetch-config-block.sh \
	${channelId} \
	${ordererAddr} \
	${mspId} \
	${PWD}/msp-${mspId}

#bash channel-update-config.sh test01 dhentf9-oabcs1-iad.blockchain.ocp.oraclecloud.com:20003 dhentf9  ${PWD}/msp-dhentf9
#bash channel-update-config.sh channellist.txt dhentf9-oabcs1-iad.blockchain.ocp.oraclecloud.com:20003 dhentf9  ${PWD}/msp-dhentf9 msp1 msppath1

exit

mspId=VolvoFounder
endorPolicy="OR('dh0728fab2f3.member')"
peerAddr=volvofounder-bcsnativetest-iad.blockchain.test.ocp.oc-test.com:20012
ordererAddr=autof4970445621-bcsnativetest-iad.blockchain.test.ocp.oc-test.com:20003
channelId=multiinstancewith32kbpage01
ccName=multiinstancewith32kbpageCC01
ccVersion=v1
ccLabel=${ccName}_${ccVersion}
ccPkg=${ccName}.tar.gz
packageId="${ccName}:bed6b22c90562f2f87d2303895064718c6fa98566a637b58b4037c5082f52777"

#bash cc-package.sh ${mspId} ${ccName} $PWD/${ccName} ${ccLabel}
#bash cc-install.sh ${mspId} ${peerAddr} ${ccPkg}
#bash cc-approve.sh ${mspId} ${channelId} ${peerAddr} ${ordererAddr} ${ccName} ${ccVersion} ${packageId} ${endorPolicy}
#bash cc-commit.sh ${mspId} ${channelId} ${peerAddr} ${ordererAddr} ${ccName} ${ccVersion} ${endorPolicy}
#bash cc-invoke.sh ${mspId} ${channelId} ${peerAddr} ${ordererAddr} ${ccName}
#bash cc-list-installed.sh ${mspId} ${peerAddr}
#bash cc-list-instantiated.sh ${mspId} ${channelId} ${peerAddr}
#bash cc-getData.sh ${mspId} ${channelId} ${peerAddr} ${ccName}
#bash discover.sh ${mspId} ${channelId} ${peerAddr} ${ccName}
#bash cc-marble-test.sh ${mspId} ${channelId} ${peerAddr} ${ordererAddr} ${ccName}

#bash discover.sh VolvoFounder multiinstancewith32kbpage01 volvofounder-bcsnativetest-iad.blockchain.test.ocp.oc-test.com:20012 multiinstancewith32kbpageCC01
#bash discover.sh VolvoFounder multiinstancewith32kbpage01 volvofounder-bcsnativetest-iad.blockchain.test.ocp.oc-test.com:20013 multiinstancewith32kbpageCC01
#bash discover.sh VolvoFounder multiinstancewith32kbpage01 volvopart01-bcsnativetest-iad.blockchain.test.ocp.oc-test.com:20041 multiinstancewith32kbpageCC01
#bash discover.sh VolvoFounder multiinstancewith32kbpage01 volvopart01-bcsnativetest-iad.blockchain.test.ocp.oc-test.com:20043 multiinstancewith32kbpageCC01
