## peer channel fetch

### Under no-tls

When you set *TLS_ENABLED=false, then you can fetch blocks using following command:

```bash
$ NUM= the block's num you want to fetch
$ peer channel fetch $NUM  -o orderer.example.com:7050 -c businesschannel
```
or you can use self-defined file, such as:

```bash
$ peer channel fetch $NUM  self-define-file.block -o orderer.example.com:7050 -c businesschannel
```

For example, we `install` 4 times, and `invoke` 2 times, so we have 6 blocks in total, and we put it into `/e2e_cli/channel-artifacts`.
you can also use following command to fetch blocks:

```bash
$ peer channel fetch oldest  -o orderer.example.com:7050 -c businesschannel 
$ peer channel fetch newest  -o orderer.example.com:7050 -c businesschannel
```

### Under tls

When you set *TLS_ENABLED=true, then you can fetch blocks using following command:

```bash
$ ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
$ NUM= the block's num you want to fetch
$ peer channel fetch $NUM  -o orderer.example.com:7050 -c businesschannel --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA  |xargs mv true businesschannel_$NUM.block
$ peer channel fetch oldest  -o orderer.example.com:7050 -c businesschannel  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA  |xargs mv true businesschannel_oldest.block
$ peer channel fetch newest  -o orderer.example.com:7050 -c businesschannel  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA  |xargs mv true businesschannel_newest.block
```

temporarily cannot support specify self-defined-file.