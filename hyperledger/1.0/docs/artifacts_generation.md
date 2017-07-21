## Usage of cryptogen and configtxgen

As we already put the orderer_genesis.block, channel.tx, Org1MSPanchors.tx, Org2MSPanchors.tx under e2e_cli/channel-artifacts/.
and put cryptographic materials to e2e_cli/crypto_config. So this doc will explain how we use cryptogen and configtxgen those two foundamental tools to manually create artifacts and certificates.

> Artifacts:
> * `orderer_genesis.block`: Genesis block for the ordering service
> * `channel.tx`: Channel transaction file for peers broadcast to the orderer at channel creation time.
> * `Org1MSPanchors.tx`, `Org2MSPanchors.tx`: Anchor peers, as the name described, use for specify each Org's anchor peer on this channel.

> Certificates:
> * All files under crypto-config.

### cryptogen

This tool will generate the x509 certificates used to identify and authenticate the various components in the network.

First boot network through `docker-compose-2orgs-4peers.yaml`

```bash
$ (sudo) docker-compose -f docker-compose-2orgs-4peers.yaml up
```

and execute `cryptogen generate` command

```bash
$ cryptogen generate --config=/etc/hyperledger/fabric/crypto-config.yaml --output ./crypto
```
cryptogen will read configuration from `crypto-config.yaml`, so if we want to add(change) Orgs or perrs topology, we should change this file first.

> The results will save under directory crypto, and this directory has mounted from host, defined in the `docker-compose-2orgs-4peers.yaml.yaml`.
> for more information refer to Example2


### [configtxgen](http://hyperledger-fabric.readthedocs.io/en/latest/configtxgen.html?highlight=crypto#)

This tool will generate genesis block, channel configuration transaction and update anchor peer.
the following is a general steps after changing the configtx.yaml.

The `configtxgen` tool is in `/go/bin/`, and when it's executed,
it will read configuration from `/etc/hyperledger/fabric/configtx.yaml`,
So if we want to regenerate `orderer.genesis.block` and `channel.tx`, we should
replace `configtx.yaml` using our own configtx.yaml first.

#### Create orderer genesis block

```bash
root@cli: configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/orderer.genesis.block
```

#### Create channel transaction artifact

```bash
root@cli: CHANNEL_NAME=businesschannel
root@cli: configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID ${CHANNEL_NAME}
```
`channel.tx` is used for generating new channel `businesschannel`

#### Update anchor peer for Organizations on the channel

Chose peer peer0.org1.example.com as org1's anchor peer, and peer0.org2.example.com as org2's anchor peer.
```bash
root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org1MSP
```

```bash
root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org2MSP
```

> more details refer to Example2

### Examples

#### Example1: how to add and re-join a new channel

This example will explain how to add a new channel without change basic topology that desigend in configtx.yaml and crypto-config.yaml.
start a fabric network with `docker-compose-1peer.yaml`, and into container fabric-cli

* 1 Regenerate `channel.tx` using with new channel name

Create channel configuration for the to-be-created `testchannel`.

```bash
$ root@cli: CHANNEL_NAME=testchannel
$ root@cli: configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID ${CHANNEL_NAME}
```

* 2 regenerate anchor peer configuratoin for Organizations

```bash
$ root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org1MSP

$ root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org2MSP
```

*  (optional)execute auto-test script

    You can skip this step, this will quickly check whether the network works, and also you can verify manually.
```bash
$ root@cli: bash ./peer/scripts/test_1peer.sh testchannel
```

* 3 Create new channel

```bash
$ root@cli: peer channel create -o orderer.example.com:7050 -c ${CHANNEL_NAME} -f ./channel-artifacts/channel.tx
```

check whether genrated new block `testchannel.block`

```bash
root@cli: ls testchannel.block
testchannel.block
```

* 4 Join new channel

    Join peer0.org1.example.com to the new channel

```bash
$ root@cli: peer channel join -b ${CHANNEL_NAME}.block -o orderer.example.com:7050

Peer joined the channel!
```

check whether success

```bash
$ root@cli: peer channel list

Channels peers has joined to:
	 testchannel
```

* 5 Update anchor peer

```bash
$ root@cli: peer channel create -o orderer.example.com:7050 -c ${CHANNEL_NAME} -f ./channel-artifacts/Org1MSPanchors.tx
```

* 6 Install 

```bash
peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02
```

* 7 Instantiate

```bash
root@cli: peer chaincode instantiate -o orderer.example.com:7050 -C ${CHANNEL_NAME} -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR ('Org1MSP.member')"
```

* 8 Query

```bash
root@cli: peer chaincode query -C ${CHANNEL_NAME} -n mycc -c '{"Args":["query","a"]}'
```

The output should be:

```bash
Query Result: 100
UTC [main] main -> INFO 008 Exiting.....
```



#### Example2: how to add an organization or peer

This example will explain how to add a new org or peer with changed the basic topology that desigend in configtx.yaml and crypto-config.yaml.

##### all-in-one

We privide some instance in current directory, in this case we add a new organization `Org3` and new peer `peer0.org3.example.com`.

* 1 Generate necessary config and certs

```bash
$ sudo docker-compose -f docker-compose-2orgs-4peers-event.yaml up
$ docker exec -it fabric-cli bash
$ root@cli: ./scripts/add-org.sh
```

> ** notice: For docker-compose-file clean, we did not mount these in the container, you need to mount yourself.

* 2 Re-setup network

```bash
echo "clean containers...."
docker rm -f `docker ps -aq`

echo "clean images ..."
docker rmi -f `docker images|grep mycc-1.0|awk '{print $3}'`
```

```bash
$ sudo docker-compose -f docker-compose-2orgs-4peers-event.yaml up
```

* 3 execute auto-test

    Throuth this script to test whether the network works.
```bash
$ root@cli: bash ./scripts/test-5-peers.sh newchannel
```

The final output may look like following

```bash
===================== Query on PEER4 on channel 'newchannel' is successful ===================== 

===================== All GOOD, End-2-End execution completed ===================== 

```


##### manually

* 1 Modify config

    modify configtx.yaml, crypto-cnfig.yaml and docker-compose files to adapt new change. and replace old file.

* 2 Bootstrap network with `docker-compose-2orgs-4peers-event.yaml`

```bash
$  docker-compose -f docker-compose-2orgs-4peers-event.yaml up
```

> notes:You may encounter some errors at startup and some peers can't start up, It's innocuous, ignore it,
because we will restart later, and now we just use tools in cli container.


* 3 Generate new certificates

```bash
$ cryptogen generate --config=/etc/hyperledger/fabric/crypto-config.yaml --output ./crypto
```

* 4 Create the genesis block

```bash
root@cli: configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/orderer_genesis.block
```

* 5 Create the configuration tx

```bash
root@cli: CHANNEL_NAME=newchannel
root@cli: configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID ${CHANNEL_NAME}
```
`channel.tx` is used for generating new channel `newchannel`

* 6 Define the anchor peer for Orgs on the channel

```bash
root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org1MSP

root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org2MSP

root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org3MSP
```

* 7 Restart network

    As we have changed the configtx.yaml and regenerate `orderer_genesis.block`,
    we'd better restart orderering service or all the service.
    now we clean all the old service and boot a new network.

```bash
echo "clean containers...."
docker rm -f `docker ps -aq`

echo "clean images ..."
docker rmi -f `docker images|grep mycc-1.0|awk '{print $3}'`
```

```bash
$ sudo docker-compose -f docker-compose-2orgs.yml up
```

* 8 Execute auto-test script

    Until this step, we complete the network re-setup, and then we will test whether it works.

```bash
$ root@cli: bash ./scripts/test-5-peers.sh
```

If the network works well. the output may looklike:

```bash

===================== All GOOD, End-2-End execution completed ===================== 

```
