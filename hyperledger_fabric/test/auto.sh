#bash fetch-config-block.sh dhanNodeOUf1 testchainid dhannodeouf1-bcsnativetest-iad.blockchain.test.ocp.oc-test.com:20003
#bash fetch-config-block.sh dhanNodeOUf1 nodeouchannel01 dhannodeouf1-bcsnativetest-iad.blockchain.test.ocp.oc-test.com:20003

mspId=AutoF4970445621
endorPolicy="OR('dh0728fab2f3.member')"
peerAddr=autof4970445621-bcsnativetest-iad.blockchain.test.ocp.oc-test.com:20009
#peerAddr=autop4970512879-bcsnativetest-iad.blockchain.test.ocp.oc-test.com:20009
ordererAddr=autof4970445621-bcsnativetest-iad.blockchain.test.ocp.oc-test.com:20003
channelId=volvotestmultiorg3
ccName=volvooriginal3
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
bash discover.sh ${mspId} ${channelId} ${peerAddr} ${ccName}
#bash cc-marble-test.sh ${mspId} ${channelId} ${peerAddr} ${ordererAddr} ${ccName}
