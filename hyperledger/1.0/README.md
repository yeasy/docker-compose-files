# Hyperledger fabric 1.0

Here we give steps on how to setup a fabric 1.0 cluster, and then use it to run chaincode tests.

If you're not familiar with Docker and Blockchain, can have a look at 2 books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)

## Environment Setup

tldr :)

With Ubuntu/Debian, you can simple use the following script to setup the environment in one instruction.

```sh
$ bash setup_fabric_1.0.sh
```

If you want to setup the environment manually, then can follow the below steps in this section.

### Download Images

Pull necessary images of peer, orderer, ca, and base image.

```sh
$ bash scripts/start_fabric.sh
```

There are also some community [images](https://hub.docker.com/r/hyperledger/) at Dockerhub, use at your own choice.


### Bootup Fabric 1.0

Start a MVE fabric cluster. All the peers joined the default channel `testchainid`.

```sh
$ docker-compose up
```

Check the output log that the peer is connected to the ca and orderer successfully.

There will be 4 running containers.

```bash
$ docker ps -a
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                                             NAMES
44b6870b0802        hyperledger/fabric-peer      "bash -c 'while tr..."   33 seconds ago      Up 32 seconds       7050-7059/tcp                                     fabric-cli
ed2c4927c0ed        hyperledger/fabric-peer      "peer node start -..."   33 seconds ago      Up 32 seconds       7050/tcp, 7052-7059/tcp, 0.0.0.0:7051->7051/tcp   fabric-peer0
af5ba8f213bb        hyperledger/fabric-orderer   "orderer"                34 seconds ago      Up 33 seconds       0.0.0.0:7050->7050/tcp                            fabric-orderer0
bbe31b98445f        hyperledger/fabric-ca        "fabric-ca-server ..."   34 seconds ago      Up 33 seconds       7054/tcp, 0.0.0.0:7054->7054/tcp
```

## Use default channel

By default, all the peer will join the default chain of `testchainid`.

```bash
$ docker exec -it fabric-cli bash
$ peer channel list  
Channels peers has joined to:
	 testchainid
UTC [main] main -> INFO 001 Exiting.....
```

After the cluster is synced successfully, you can validate by install/instantiate, invoking or querying chaincode from the container or from the host.

### install&instantiate
Use `docker exec -it fabric-cli bash` to open a bash inside container `fabric-cli`, which will accept our chaincode testing commands of `install&instantiate`, `invoke` and `query`.

Inside the container, run the following command to install a new chaincode of the example02. The chaincode will initialize two accounts: `a` and `b`, with value of `100` and `200`.

```bash
$ peer chaincode install -v 1.0 -n test_cc -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02
```
This will take a while, and the result may look like following.

```bash
[golang-platform] writeGopathSrc -> INFO 001 rootDirectory = /go/src
container] WriteFolderToTarPackage -> INFO 002 rootDirectory = /go/src
[main] main -> INFO 003 Exiting.....
```

Then instantiate the chaincode test_cc on defaule channel testchainid.
```bash
$ peer chaincode instantiate -v 1.0 -n test_cc -c '{"Args":["init","a","100","b","200"]}' -o orderer0:7050
```

This will take a while, and the result may look like following:

```bash
UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
UTC [main] main -> INFO 003 Exiting.....
```

There should be no error in the return log, and in the peer nodes's output. 
Wait several seconds till the deploy is finished.

If the `peer chaincode install` and `peer chaincode instantiate` commands are executed successfully, there will generate a new chaincode container, besides the 4 existing one, name like `dev-peer0-test_cc-1.0`.
```bash
$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                                             NAMES
cf7bf529f214        dev-peer0-test_cc-1.0        "chaincode -peer.a..."   58 seconds ago      Up 58 seconds                                                         dev-peer0-test_cc-1.0
44b6870b0802        hyperledger/fabric-peer      "bash -c 'while tr..."   14 minutes ago      Up 14 minutes       7050-7059/tcp                                     fabric-cli
ed2c4927c0ed        hyperledger/fabric-peer      "peer node start -..."   14 minutes ago      Up 14 minutes       7050/tcp, 7052-7059/tcp, 0.0.0.0:7051->7051/tcp   fabric-peer0
af5ba8f213bb        hyperledger/fabric-orderer   "orderer"                14 minutes ago      Up 14 minutes       0.0.0.0:7050->7050/tcp                            fabric-orderer0
bbe31b98445f        hyperledger/fabric-ca        "fabric-ca-server ..."   14 minutes ago      Up 14 minutes       7054/tcp, 0.0.0.0:7054->7054/tcp                  fabric-ca

```

And will also generate a new chaincode image, name like `dev-peer0-test_cc-1.0`.
```bash
$ docker images
REPOSITORY                         TAG                    IMAGE ID            CREATED              SIZE
dev-peer0-test_cc-1.0              latest                 84e5422eead5        About a minute ago   176 MB
...
```

### Query
Inside the container, query the existing value of `a` and `b`.

*Notice that the query method can be called by invoke a transaction.*

```bash
$ peer chaincode query -n test_cc -c '{"Args":["query","a"]}'
```

The final output may look like the following, with a payload value of `100`.

```bash
Query Result: 100
[main] main -> INFO 001 Exiting.....
```

Query the value of `b`

```bash
$ peer chaincode query -n test_cc -c '{"Args":["query","b"]}' -o orderer0:7050
```

The final output may look like the following, with a payload value of `200`.

```bash
Query Result: 200
[main] main -> INFO 001 Exiting.....
```


### Invoke
Inside the container, invoke a transaction to transfer `10` from `a` to `b`.

```bash
$ peer chaincode invoke -n test_cc -c '{"Args":["invoke","a","b","10"]}' -o orderer0:7050
```

The final result may look like the following, the response should be `OK`.

```bash
[chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Invoke result: version:1 response:<status:200 message:"OK" > payload:"\n \215\263\337\322u\323?\242t$s\035l\270Ta\270\270+l6\322X\346\365k\020\215Phy\260\022C\n<\002\004lccc\001\007test_cc\004\001\001\001\001\000\000\007test_cc\002\001a\004\001\001\001\001\001b\004\001\001\001\001\002\001a\000\00290\001b\000\003210\000\032\003\010\310\001" endorsement:<endorser:"\n\007DEFAULT\022\232\007-----BEGIN -----\nMIICjDCCAjKgAwIBAgIUBEVwsSx0TmqdbzNwleNBBzoIT0wwCgYIKoZIzj0EAwIw\nfzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNh\nbiBGcmFuY2lzY28xHzAdBgNVBAoTFkludGVybmV0IFdpZGdldHMsIEluYy4xDDAK\nBgNVBAsTA1dXVzEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMTYxMTExMTcwNzAw\nWhcNMTcxMTExMTcwNzAwWjBjMQswCQYDVQQGEwJVUzEXMBUGA1UECBMOTm9ydGgg\nQ2Fyb2xpbmExEDAOBgNVBAcTB1JhbGVpZ2gxGzAZBgNVBAoTEkh5cGVybGVkZ2Vy\nIEZhYnJpYzEMMAoGA1UECxMDQ09QMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE\nHBuKsAO43hs4JGpFfiGMkB/xsILTsOvmN2WmwpsPHZNL6w8HWe3xCPQtdG/XJJvZ\n+C756KEsUBM3yw5PTfku8qOBpzCBpDAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYw\nFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFOFC\ndcUZ4es3ltiCgAVDoyLfVpPIMB8GA1UdIwQYMBaAFBdnQj2qnoI/xMUdn1vDmdG1\nnEgQMCUGA1UdEQQeMByCCm15aG9zdC5jb22CDnd3dy5teWhvc3QuY29tMAoGCCqG\nSM49BAMCA0gAMEUCIDf9Hbl4xn3z4EwNKmilM9lX2Fq4jWpAaRVB97OmVEeyAiEA\n25aDPQHGGq2AvhKT0wvt08cX1GTGCIbfmuLpMwKQj38=\n-----END -----\n" signature:"0E\002!\000\271\232\230\261\336\352ow\021V3\224\252\217\362vzM'\213\376@2\306/\201=\213\023\244\310%\002 \014\277\362|\223\342\277Pk5(\004\331\014\021\307\273\351/]:\020\232\013d\261\035+\266\265\305<" > 
[main] main -> INFO 002 Exiting.....
```

### Query
Query again the existing value of `a` and `b`.

```bash
$ peer chaincode query -n test_cc -c '{"Args":["query","a"]}'
```
The new value of `a` should be 90.

```bash
$ peer chaincode query -n test_cc -c '{"Args":["query","b"]}'
```
The new value of `b` should be 210.

## Use new created channel (Optional)

Start the Docker Compose project with `docker-compose-new-channel.yml`.

```bash
$ docker-compose -f docker-compose-new-channel.yml up
```

There will be several containers running successfully.

```bash
$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED              STATUS              PORTS                                                                               NAMES
6688f290a9b9        hyperledger/fabric-peer      "bash -c 'while tr..."   About a minute ago   Up About a minute   7050-7059/tcp                                                                       fabric-cli
6ddbbd972ac3        hyperledger/fabric-peer      "peer node start -..."   About a minute ago   Up About a minute   7050/tcp, 0.0.0.0:7051->7051/tcp, 7052/tcp, 7054-7059/tcp, 0.0.0.0:7053->7053/tcp   peer0.org1.example.com
4afc759e0dc9        hyperledger/fabric-orderer   "orderer"                About a minute ago   Up About a minute   0.0.0.0:7050->7050/tcp                                                              orderer.example.com
bea1154c7162        hyperledger/fabric-ca        "fabric-ca-server ..."   About a minute ago   Up About a minute   7054/tcp, 0.0.0.0:7054->7054/tcp                                                    fabric-ca
```

### Auto testing operation (optional)

Run this script will check whether the MVE bootstrap success.

```bash
$ docker exec -it fabric-cli bash
$ ./peer/scripts/new-channel-auto-test.sh
```

### Manually create artifacts (optional)

**Skip this step**, as we already put the needed artifacts `orderer.genesis.block` and `channel.tx` under `e2e_cli/channel-artifacts/`.

Detailed steps in [GenerateArtifacts](./GenerateArtifacts.md) explains the creation of `orderer.genesis.block` (needed by orderer to bootup) and `channel.tx` (needed by cli to create new channel) and crypto related configuration files.

### Create new channel

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

### Join the channel

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

### Update anchor peers 

The `configtx.yaml` file contains the definitions for our sample network and presents the topology of the network components - three members (OrdererOrg, Org1 & Org2), But in this MVE, we just use OrdererOrg and Org1, org1 has only peer(pee0.org1), and chose it as anchor peers for Org1. 

```bash
$ peer channel create -o orderer.example.com:7050 -c ${CHANNEL_NAME} -f ./peer/channel-artifacts/Org1MSPanchors.tx
```

### Install&Instantiate

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

### Query

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


### Invoke

Inside the container, invoke a transaction to transfer `10` from `a` to `b`.

```bash
$ peer chaincode invoke -o orderer.example.com:7050 -C ${CHANNEL_NAME} -n mycc -c '{"Args":["invoke","a","b","10"]}'
```

The result may look like following:

```bash
UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Invoke result: version:1 response:<status:200 message:"OK" > payload:"\n qm\251\207\312\277\256\261b\317:\300\000\014\203`\005\304\254\304,$a\360\327\010\342\342/y]\323\022X\nQ\022\031\n\004lccc\022\021\n\017\n\007test_cc\022\004\010\001\020\001\0224\n\007test_cc\022)\n\t\n\001a\022\004\010\001\020\001\n\t\n\001b\022\004\010\001\020\001\032\007\n\001a\032\00290\032\010\n\001b\032\003210\032\003\010\310\001" endorsement:<endorser:"\n\007Org0MSP\022\210\004-----BEGIN -----\nMIIBYzCCAQmgAwIBAwICA+gwCgYIKoZIzj0EAwIwEzERMA8GA1UEAwwIcGVlck9y\nZzAwHhcNMTcwMjIwMTkwNjExWhcNMTgwMjIwMTkwNjExWjAQMQ4wDAYDVQQDDAVw\nZWVyMDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABEF6dfqjqfbIgZuOR+dgoJMl\n/FaUlGI70A/ixmVUY83Yp4YtV3FDBSOPiO5O+s8pHnpbwB1LqhrxAx1Plr0M/UWj\nUDBOMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFBY2bc84vLEwkX1fSAER2p48jJXw\nMB8GA1UdIwQYMBaAFFQzuQR1RZP/Qn/BNDtGSa8n4eN/MAoGCCqGSM49BAMCA0gA\nMEUCIQDeDZ71L+OTYcbbqiDNRf0L8OExO59mH1O3xpdwMAM0MgIgXySG4sv9yV31\nWcWRFfRFyu7o3T72kqiLZ1nkDuJ8jWI=\n-----END -----\n" signature:"0E\002!\000\220M'\245\230do\310>\277\251j\021$\250\237H\353\377\331:\230\362n\216\224~\033\240\006\367%\002 \014\240|h\346\250\356\372\353\301;#\372\027\276!\252F\334/\221\210\254\215\363\235\341v\217\236\274<" >
2017-04-06 09:47:15.993 UTC [main] main -> INFO 002 Exiting.....
```

### Query

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


## Acknowledgement
* [Hyperledger Fabric](https://github.com/hyperledger/fabric/) project.
* [Hyperledger Fabric Getting Started](http://hyperledger-fabric.readthedocs.io/en/latest/getting_started.html).
