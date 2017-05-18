## Usage of `cryptogen` and `configtxgen` 

As we already put the `orderer.genesis.block`, `channel.tx`, `Org1MSPanchors.tx`, `Org2MSPanchors.tx` under `e2e_cli/channel-artifacts/`.
and put cryptographic materials to `e2e_cli/crypto_config`. So this doc will explain how we use `cryptogen` and `configtxgen` those two foundamental tools to manually create artifacts and certificates.

> Artifacts:

> * `orderer.genesis.block`: Genesis block for the ordering service

> * `channel.tx`: Channel transaction file for peers broadcast to the orderer at channel creation time.

> * `Org1MSPanchors.tx`, `Org2MSPanchors.tx`: Anchor peers, as the name described, use for specify each Org's anchor peer on this channel.

> Cerfiricates:

> * All files in crypto-config.

### cryptogen

This tool will generate the x509 certificates used to identify and authenticate the various components in the network.

First boot network through `docker-compose-2orgs.yml`

```bash
$ (sudo) docker-compose -f docker-compose-2orgs.yml up
```

and execute `cryptogen generate` command

```bash
$ cryptogen generate --config=./peer/crypto-config.yaml --output ./peer/crypto
```
cryptogen will read configuration from `crypto-config.yaml`, so if we want to add(change) Orgs or perrs topology, wo should change this file first and then execute this command.

> The results will save at directory crypto, and this directory was mounted from host which describe detailed at `docker-compose-2orgs.yaml`.
>
> Refer to Example2


### [configtxgen](http://hyperledger-fabric.readthedocs.io/en/latest/configtxgen.html?highlight=crypto#)

This tool will generate genesis block, channel configuration transaction and anchor peer update transactions.

#### Replace default configtx.yaml

```bash
root@cli: cp ./peer/configtx.yaml /etc/hyperledger/fabric
```

The `configtxgen` tool is in `/go/bin/`, and when it's executed,
it will read configuration from `/etc/hyperledger/fabric/configtx.yaml`,
So if we want to regenerate `orderer.genesis.block` and `channel.tx`, we should
replace `configtx.yaml` using our own configtx.yaml first.

#### Create the genesis block

```bash
root@cli: configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./peer/channel-artifacts/orderer.genesis.block
```

#### Create the configuration tx

```bash
root@cli: CHANNEL_NAME=mychannel
root@cli: configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./peer/channel-artifacts/channel.tx -channelID ${CHANNEL_NAME}
```
`channel.tx` is used for generating new channel `mychannel`

> Note: the channelID can be whatever you want. and refer to Example1

#### Define the anchor peer for Org1 on the channel

```bash
root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./peer/channel-artifacts/Org1MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org1MSP
```

#### Define the anchor peer for Org2 on the channel

```bash
root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./peer/channel-artifacts/Org2MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org2MSP
```

> more details refer to Example2

### Example1: how to add or change channel

This example will explain how to add a new channel without change basic topology which desigend in configtx.yaml and crypto-config.yaml.

Create channel configuration transaction for the to-be-created `testchain`.

* 1 Regenerate `channel.tx`

    Fist boot MVE using `docker-compose-new-channel.yml`

```bash
$ root@cli:pwd
  /go/src/github.com/hyperledger/fabric
$ root@cli: CHANNEL_NAME=testchannel
$ root@cli: cp ./peer/configtx.yaml /etc/hyperledger/fabric
$ root@cli: configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./peer/channel-artifacts/channel.tx -channelID ${CHANNEL_NAME}
```

* 2 Update anchor peer config for Org1MSP

```bash
$ root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./peer/channel-artifacts/Org1MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org1MSP
```

* 3 Update anchor peer config for Org2msp

```bash
$ root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./peer/channel-artifacts/Org2MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org2MSP
```

* 4 (optional)execute auto-test script

    You can skip this step and manually verify.
```bash
$ root@cli: ./peer/scripts/new-channel-auto-test.sh testchannel
```

* 5 Create new channel

```bash
$ root@cli: peer channel create -o orderer.example.com:7050 -c ${CHANNEL_NAME} -f ./peer/channel-artifacts/channel.tx
```

    check whether genrate new block `testchannel.block`

```bash
root@cli: ls testchannel.block
testchannel.block
```

* 6 Join peer0,org1.example.com in new channel

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

* 7 Update anchor peer

```bash
$ root@cli: peer channel create -o orderer.example.com:7050 -c ${CHANNEL_NAME} -f ./peer/channel-artifacts/Org1MSPanchors.tx
```

* 8 Install 

```bash
peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02
```

* 9 Instantiate

```bash
root@cli: peer chaincode instantiate -o orderer.example.com:7050 -C ${CHANNEL_NAME} -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR ('Org1MSP.member')"
```

* 10 Query

```bash
root@cli: peer chaincode query -C ${CHANNEL_NAME} -n mycc -c '{"Args":["query","a"]}'
```

    The output should be:

```bash
Query Result: 100
UTC [main] main -> INFO 008 Exiting.....
```

### Example2: how to Add an organization or peer

#### all-in-one

We privide some [instance](./example2), in this case we add a new organization `Org3` and new peer `peer0.org3.example.com`.

* 1 Replace docker-compose files

```bash
$ git clone https://github.com/yeasy/docker-compose-files.git
$ cd docker-compose-files/hyperledger/1.0
$ cp ./example2/docker-compose-2orgs.yml ./example2/peer-base.yml .
```
* 2 Generate necessary config and certs

```bash
$ sudo docker-compose -f docker-compose-2orgs.yml up
$ docker exec -it fabric-cli bash
$ root@cli: ./peer/example2/add-org.sh
```

* 3 Restart network

```bash
echo "clean containers...."
docker rm -f `docker ps -aq`

echo "clean images ..."
docker rmi -f `docker images|grep mycc-1.0|awk '{print $3}'`
```

```bash
$ sudo docker-compose -f docker-compose-2orgs.yml up
```

* 4 execute auto-test

```bash
$ root@cli: ./peer/scripts/new-channel-auto-test-5-peers.sh newchannel
```

The final output may look like following

```bash
===================== Query on PEER4 on channel 'newchannel' is successful ===================== 

===================== All GOOD, End-2-End execution completed ===================== 

```


#### manually

* 1 Modify config

    modify configtx.yaml, crypto-cnfig.yaml and docker-compose files to adapt new change. and replace old file.

* 2 Bootstrap network with `docker-compose-2orgs.yml`

```bash
$  docker-compose -f docker-compose-2orgs.yml up
```

    You may encounter some errors at startup and some peers can't start up, It's innocuous, ignore it,

    Because we will restart later, and now we just use tools in cli container.

* 3 Replace default configtx.yaml

```bash
root@cli: cp ./peer/configtx.yaml /etc/hyperledger/fabric
```

* 4 Generate new certificates

```bash
$ cryptogen generate --config=./peer/crypto-config.yaml --output ./peer/crypto
```

* 5 Create the genesis block

```bash
root@cli: configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./peer/channel-artifacts/orderer.genesis.block
```

* 6 Create the configuration tx

```bash
root@cli: CHANNEL_NAME=newchannel
root@cli: configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./peer/channel-artifacts/channel.tx -channelID ${CHANNEL_NAME}
```
`channel.tx` is used for generating new channel `mychannel`

* 7 Define the anchor peer for Org1 on the channel

```bash
root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./peer/channel-artifacts/Org1MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org1MSP
```

* 8 Define the anchor peer for Org2 on the channel

```bash
root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./peer/channel-artifacts/Org2MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org2MSP
```

* 9 Define the anchor peer for Org3 on the channel

```bash
root@cli: configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./peer/channel-artifacts/Org3MSPanchors.tx -channelID ${CHANNEL_NAME} -asOrg Org3MSP
```

* 10 Restart network

    As we have changed the configtx.yaml and regenerate `orderer.genesis.block`,
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

* 11 Execute auto-test script

```bash
$ root@cli: ./peer/scripts/new-channel-auto-test-5-peers.sh
```

The output may looklike:

```bash

===================== All GOOD, End-2-End execution completed ===================== 

```
