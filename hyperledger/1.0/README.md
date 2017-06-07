# Hyperledger fabric 1.0

Here we give steps on how to setup a fabric 1.0 cluster, and then use it to run chaincode tests.

If you're not familiar with Docker and Blockchain, can have a look at 2 books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)

## Environment Setup

tldr :)

With Ubuntu/Debian, you can simple use the following scripts to setup the environment and start the fabric network.

```sh
$ bash scripts/setup_Docker.sh  # Install Docker, Docker-Compose 
  bash scripts/download_images.sh  # Pull required Docker images
  bash scripts/start_fabric.sh
```

If you want to setup the environment manually, then can follow the below steps in this section.

### Download Images

Pull necessary images of peer, orderer, ca, and base image.

```sh
$ bash scripts/download_images.sh
```

There are also some community [images](https://hub.docker.com/r/hyperledger/) at Dockerhub, use at your own choice.


### Bootup Fabric 1.0

Start a  fabric cluster.

```sh
$ docker-compose -f docker-compose-2orgs.yml up
```

Or

```bash
$ bash scripts/start_fabric.sh
```

Check the output log that the peer is connected to the ca and orderer successfully.

There will be 7 running containers, include 4 peers, 1 cli, 1 ca and 1 orderer.

```bash
$ docker ps -a
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                                                                                 NAMES
8683435422ca        hyperledger/fabric-peer      "bash -c 'while true;"   19 seconds ago      Up 18 seconds       7050-7059/tcp                                                                         fabric-cli
f284c4dd26a0        hyperledger/fabric-peer      "peer node start --pe"   22 seconds ago      Up 19 seconds       7050/tcp, 0.0.0.0:7051->7051/tcp, 7052/tcp, 7054-7059/tcp, 0.0.0.0:7053->7053/tcp     peer0.org1.example.com
95fa3614f82c        hyperledger/fabric-ca        "fabric-ca-server sta"   22 seconds ago      Up 19 seconds       0.0.0.0:7054->7054/tcp                                                                fabric-ca
833ca0d8cf41        hyperledger/fabric-orderer   "orderer"                22 seconds ago      Up 19 seconds       0.0.0.0:7050->7050/tcp                                                                orderer.example.com
cd21cfff8298        hyperledger/fabric-peer      "peer node start --pe"   22 seconds ago      Up 20 seconds       7050/tcp, 7052/tcp, 7054-7059/tcp, 0.0.0.0:9051->7051/tcp, 0.0.0.0:9053->7053/tcp     peer0.org2.example.com
372b583b3059        hyperledger/fabric-peer      "peer node start --pe"   22 seconds ago      Up 20 seconds       7050/tcp, 7052/tcp, 7054-7059/tcp, 0.0.0.0:10051->7051/tcp, 0.0.0.0:10053->7053/tcp   peer1.org2.example.com
47ce30077276        hyperledger/fabric-peer      "peer node start --pe"   22 seconds ago      Up 20 seconds       7050/tcp, 7052/tcp, 7054-7059/tcp, 0.0.0.0:8051->7051/tcp, 0.0.0.0:8053->7053/tcp     peer1.org1.example.com
```

#### Test fabric network

Run the test script.

```bash
$ docker exec -it fabric-cli bash
$ bash ./peer/scripts/new-channel-auto-test-4-peers.sh
```

You should see the following output:

```bash
UTC [msp] GetLocalMSP -> DEBU 004 Returning existing local MSP
UTC [msp] GetDefaultSigningIdentity -> DEBU 005 Obtaining default signing identity
UTC [msp/identity] Sign -> DEBU 006 Sign: plaintext: 0AB1070A6708031A0C08F6DCDDC90510...6D7963631A0A0A0571756572790A0161 
UTC [msp/identity] Sign -> DEBU 007 Sign: digest: 4095B73E1AA14FE681BCF891A6E08E55D7B01FA0C2D01E69E91DD1019E9E48CB 
Query Result: 90
UTC [main] main -> INFO 008 Exiting.....
===================== Query on PEER3 on channel 'mychannel' is successful ===================== 

===================== All GOOD, End-2-End execution completed ===================== 


 _____   _   _   ____            _____   ____    _____ 
| ____| | \ | | |  _ \          | ____| |___ \  | ____|
|  _|   |  \| | | | | |  _____  |  _|     __) | |  _|  
| |___  | |\  | | |_| | |_____| | |___   / __/  | |___ 
|_____| |_| \_| |____/          |_____| |_____| |_____|
```

## Use MVE to Explain the steps

This part we will explain the detail steps to operate the chaincode.
first start fabric network with `docker-compose-new-channel.yml`, and we will obtain the basic environmet that can be operated.

```bash
$ docker-compose -f docker-compose-new-channel.yml up
```

There will be 4 containers running successfully.

```bash
$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED              STATUS              PORTS                                                                               NAMES
6688f290a9b9        hyperledger/fabric-peer      "bash -c 'while tr..."   About a minute ago   Up About a minute   7050-7059/tcp                                                                       fabric-cli
6ddbbd972ac3        hyperledger/fabric-peer      "peer node start -..."   About a minute ago   Up About a minute   7050/tcp, 0.0.0.0:7051->7051/tcp, 7052/tcp, 7054-7059/tcp, 0.0.0.0:7053->7053/tcp   peer0.org1.example.com
4afc759e0dc9        hyperledger/fabric-orderer   "orderer"                About a minute ago   Up About a minute   0.0.0.0:7050->7050/tcp                                                              orderer.example.com
bea1154c7162        hyperledger/fabric-ca        "fabric-ca-server ..."   About a minute ago   Up About a minute   7054/tcp, 0.0.0.0:7054->7054/tcp                                                    fabric-ca
```

### Manually testing

#### Create artifacts

**Skip this step**, as we already put the needed artifacts `orderer_genesis.block` and `channel.tx` under `e2e_cli/channel-artifacts/`.

Detailed steps in [GenerateArtifacts](./GenerateArtifacts.md) explains the creation of `orderer_genesis.block` (needed by orderer to bootup) and `channel.tx` (needed by cli to create new channel) and crypto related configuration files.

#### Create new channel

Create a new channel named `mychannel` with the existing `channel.tx` file.

```bash
$ docker exec -it fabric-cli bash
$ CHANNEL_NAME="mychannel"
peer channel create -o orderer.example.com:7050 -c ${CHANNEL_NAME} -f ./peer/channel-artifacts/channel.tx
```
The cmd will return lots of info, which is the content of the configuration block.

And a block with the same name of the channel will be created locally.

```bash
$ ls mychannel.block
mychannel.block
```

Check the log output of `orderer.example.com`, should find some message like

```bash
orderer.example.com | UTC [orderer/multichain] newChain -> INFO 004 Created and starting new chain newchannel
```

#### Join the channel

Use the following command to join `peer0.org1.example.com` the channel

```bash
$ peer channel join -b ${CHANNEL_NAME}.block

Peer joined the channel!
``` 

Will receive the `Peer joined the channel!` response if succeed.

Then use the following command, we will find the channels that peers joined.

```bash
$ peer channel list
Channels peers has joined to:
	 mychannel
2017-04-11 03:44:40.313 UTC [main] main -> INFO 001 Exiting.....
```

#### Update anchor peers 

The `configtx.yaml` file contains the definitions for our sample network and presents the topology of the network components - three members (OrdererOrg, Org1 & Org2), But in this MVE, we just use OrdererOrg and Org1, org1 has only peer(pee0.org1), and chose it as anchor peers for Org1. 

```bash
$ peer channel create -o orderer.example.com:7050 -c ${CHANNEL_NAME} -f ./peer/channel-artifacts/Org1MSPanchors.tx
```

#### Install&Instantiate

First `install` a chaincode named `mycc` to `peer0`.

```bash
$ peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02
```

This will take a while, and the result may look like following.

```bash
UTC [golang-platform] writeGopathSrc -> INFO 004 rootDirectory = /go/src
UTC [container] WriteFolderToTarPackage -> INFO 005 rootDirectory = /go/src
UTC [main] main -> INFO 006 Exiting.....
```

Then `instantiate` the chaincode mycc on channel `mychannel`, with initial args and the endorsement policy.

```bash
$ peer chaincode instantiate -o orderer.example.com:7050 -C ${CHANNEL_NAME} -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR ('Org1MSP.member')"
```

This will take a while, and the result may look like following:

```bash
UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 004 Using default escc
UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 005 Using default vscc
UTC [main] main -> INFO 006 Exiting.....
```

Now in the system, there will be a new `dev-peer0.org1.example.com-mycc-1.0` image and a `dev-peer0.org1.example.com-mycc-1.0` chaincode container.

```bash
crluser@baas-test2:~$ docker ps
CONTAINER ID        IMAGE                                 COMMAND                  CREATED              STATUS              PORTS                                                                               NAMES
7aa088c76597        dev-peer0.org1.example.com-mycc-1.0   "chaincode -peer.a..."   10 seconds ago       Up 9 seconds                                                                                            dev-peer0.org1.example.com-mycc-1.0
eb1d9c73b26b        hyperledger/fabric-peer               "bash -c 'while tr..."   About a minute ago   Up About a minute   7050-7059/tcp                                                                       fabric-cli
2d6fd4f61e2b        hyperledger/fabric-peer               "peer node start -..."   About a minute ago   Up About a minute   7050/tcp, 0.0.0.0:7051->7051/tcp, 7052/tcp, 7054-7059/tcp, 0.0.0.0:7053->7053/tcp   peer0.org1.example.com
832dcc64cc1b        hyperledger/fabric-orderer            "orderer"                About a minute ago   Up About a minute   0.0.0.0:7050->7050/tcp                                                              orderer.example.com
c87095528f76        hyperledger/fabric-ca                 "fabric-ca-server ..."   About a minute ago   Up About a minute   7054/tcp, 0.0.0.0:7054->7054/tcp                                                    fabric-ca
```

#### Query

Query the existing value of `a` and `b`.

```bash
$ peer chaincode query -C ${CHANNEL_NAME} -n mycc -c '{"Args":["query","a"]}'
```

The result may look like following, with a payload value of `100`.
```bash
Query Result: 100
[main] main -> INFO 001 Exiting.....
```

```bash
$ peer chaincode query -C ${CHANNEL_NAME} -n mycc -c '{"Args":["query","a"]}'
```

The result may look like following, with a payload value of `200`.

```bash
Query Result: 200
[main] main -> INFO 001 Exiting.....
```


#### Invoke

Inside the container, invoke a transaction to transfer `10` from `a` to `b`.

```bash
$ peer chaincode invoke -o orderer.example.com:7050 -C ${CHANNEL_NAME} -n mycc -c '{"Args":["invoke","a","b","10"]}'
```

The result may look like following:

```bash
UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Invoke result: version:1 response:<status:200 message:"OK" > payload:"\n qm\251\207\312\277\256\261b\317:\300\000\014\203`\005\304\254\304,$a\360\327\010\342\342/y]\323\022X\nQ\022\031\n\004lccc\022\021\n\017\n\007test_cc\022\004\010\001\020\001\0224\n\007test_cc\022)\n\t\n\001a\022\004\010\001\020\001\n\t\n\001b\022\004\010\001\020\001\032\007\n\001a\032\00290\032\010\n\001b\032\003210\032\003\010\310\001" endorsement:<endorser:"\n\007Org0MSP\022\210\004-----BEGIN -----\nMIIBYzCCAQmgAwIBAwICA+gwCgYIKoZIzj0EAwIwEzERMA8GA1UEAwwIcGVlck9y\nZzAwHhcNMTcwMjIwMTkwNjExWhcNMTgwMjIwMTkwNjExWjAQMQ4wDAYDVQQDDAVw\nZWVyMDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABEF6dfqjqfbIgZuOR+dgoJMl\n/FaUlGI70A/ixmVUY83Yp4YtV3FDBSOPiO5O+s8pHnpbwB1LqhrxAx1Plr0M/UWj\nUDBOMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFBY2bc84vLEwkX1fSAER2p48jJXw\nMB8GA1UdIwQYMBaAFFQzuQR1RZP/Qn/BNDtGSa8n4eN/MAoGCCqGSM49BAMCA0gA\nMEUCIQDeDZ71L+OTYcbbqiDNRf0L8OExO59mH1O3xpdwMAM0MgIgXySG4sv9yV31\nWcWRFfRFyu7o3T72kqiLZ1nkDuJ8jWI=\n-----END -----\n" signature:"0E\002!\000\220M'\245\230do\310>\277\251j\021$\250\237H\353\377\331:\230\362n\216\224~\033\240\006\367%\002 \014\240|h\346\250\356\372\353\301;#\372\027\276!\252F\334/\221\210\254\215\363\235\341v\217\236\274<" >
2017-04-06 09:47:15.993 UTC [main] main -> INFO 002 Exiting.....
```

#### Query

And then query the value of `a` and `b`.


```bash
$ peer chaincode query -C ${CHANNEL_NAME} -n mycc -c '{"Args":["query","a"]}'
```

```bash
Query Result: 90
[main] main -> INFO 001 Exiting.....
```
The value of `a` should be `90`.


```bash
$ peer chaincode query -C ${CHANNEL_NAME} -n mycc -c '{"Args":["query","b"]}'
```

The value of `b` should be `210`

```bash
Query Result: 210
[main] main -> INFO 001 Exiting.....
```

Finally, the output of the chaincode containers may look like following.

```bash
$ docker logs -f dev-peer0.org1.example.com-mycc-1.0
ex02 Init
Aval = 100, Bval = 200
ex02 Invoke
Query Response:{"Name":"a","Amount":"100"}
ex02 Invoke
Aval = 90, Bval = 210
ex02 Invoke
Query Response:{"Name":"b","Amount":"210"}
ex02 Invoke
Query Response:{"Name":"a","Amount":"90"}

```

### (optional) All-in-one testing operation

Run this script will check whether the MVE bootstrap success.

```bash
$ docker exec -it fabric-cli bash
$ bash ./peer/scripts/new-channel-auto-test.sh
```

## Acknowledgement
* [Hyperledger Fabric](https://github.com/hyperledger/fabric/) project.
* [Hyperledger Fabric Getting Started](http://hyperledger-fabric.readthedocs.io/en/latest/getting_started.html).
