# Hyperledger fabric 1.0

If you're using Ubuntu, you can use the following script to install Docker and start a fabric 1.0 Minimum Viable Environment (MVE) in one instruction.

```sh
$ bash setup_fabric_1.0.sh
```

tldr :)

If you want to explore more, then can follow these steps.

If you're not familiar with Docker and Blockchain, can have a look at 2 books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)

## Preparation

### Download Images

Pull necessary images of peer, orderer, ca, and base image.

```sh
$ ARCH=x86_64
$ BASE_VERSION=1.0.0-preview
$ PROJECT_VERSION=1.0.0-preview
$ IMG_VERSION=0.8.6
$ docker pull yeasy/hyperledger-fabric-base:$IMG_VERSION \
  && docker pull yeasy/hyperledger-fabric-peer:$IMG_VERSION \
  && docker pull yeasy/hyperledger-fabric-orderer:$IMG_VERSION \
  && docker pull yeasy/hyperledger-fabric-ca:$IMG_VERSION \
  && docker pull yeasy/blockchain-explorer:latest \
  && docker tag yeasy/hyperledger-fabric-peer:$IMG_VERSION hyperledger/fabric-peer \
  && docker tag yeasy/hyperledger-fabric-orderer:$IMG_VERSION hyperledger/fabric-orderer \
  && docker tag yeasy/hyperledger-fabric-ca:$IMG_VERSION hyperledger/fabric-ca \
  && docker tag yeasy/hyperledger-fabric-base:$IMG_VERSION hyperledger/fabric-baseimage \
  && docker tag yeasy/hyperledger-fabric-base:$IMG_VERSION hyperledger/fabric-ccenv:$ARCH-$BASE_VERSION \
  && docker tag yeasy/hyperledger-fabric-base:$IMG_VERSION hyperledger/fabric-baseos:$ARCH-$BASE_VERSION
```

There are also some community [images](https://hub.docker.com/r/hyperledger/) at Dockerhub, use at your own choice.


### Setup network

*Just ignore if you are not familiar with Docker networking configurations.*

The template can support using separate network for the chain.

By default, the feature is disabled to use the shared Docker network.

If you want to enable the feature, just un-comment the bottom networks section in the compose file and the `CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE` line in the `peer-[noops,pbft].yml` file.

Then, create the following two Docker networks.

```sh
$ docker network create fabric_noops
$ docker network create fabric_pbft
```

## Usage

### Fabric Bootup

Start a MVE fabric cluster. with the peer joined the default channel `testchainid`.

```sh
$ docker-compose up
```

Check the output log that the peer is connected to the ca and orderer successfully.

There will be 3 running containers.

```bash
$ docker ps -a
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                                             NAMES
2367ccb6463d        hyperledger/fabric-peer      "peer node start"        6 minutes ago      Up 6 minutes       7050/tcp, 7052-7059/tcp, 0.0.0.0:7051->7051/tcp   fabric-peer0
02eaf86496ca        hyperledger/fabric-orderer   "orderer"                6 minutes ago      Up 6 minutes       0.0.0.0:7050->7050/tcp                            fabric-orderer
71c2246e1165        hyperledger/fabric-ca        "fabric-ca server ..."   6 minutes ago      Up 6 minutes       7054/tcp, 0.0.0.0:8888->8888/tcp 
```

### Test chaincode with default channel

After the cluster is synced successfully, you can validate by deploying, invoking or querying chaincode from the container or from the host.

#### Deploy
Use `docker exec -it fabric-peer0 bash` to open a bash inside container `fabric-peer0`, which will accept our chaincode testing commands of `install/instantiate`, `invoke` and `query`.

Inside the container, run the following command to deploy a new chaincode of the example02. The chaincode will initialize two accounts: `a` and `b`, with value of `100` and `200`.

```bash
$ docker exec -it fabric-peer0 bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode  install -v 1.0 -n test_cc -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -c '{"Args":["init","a","100","b","200"]}' -o orderer:7050
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode  instantiate -v 1.0 -n test_cc -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -c '{"Args":["init","a","100","b","200"]}' -o orderer:7050
```

There should be no error in the return log, and in the peer nodes's output. 
Wait several seconds till the deploy is finished.

If the `peer chaincode install` and `peer chaincode instantiate` commands are executed successfully, there will generate a new chaincode container, besides the 3 existing one, name like `dev-peer0-test_cc-1.0`.
```bash
$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                                             NAMES
edc9740c265c        dev-peer0-test_cc-1.0        "/opt/gopath/bin/t..."   34 minutes ago      Up 34 minutes                                                         dev-peer0-test_cc-1.0
2367ccb6463d        hyperledger/fabric-peer      "peer node start"        36 minutes ago      Up 36 minutes       7050/tcp, 7052-7059/tcp, 0.0.0.0:7051->7051/tcp   fabric-peer0
02eaf86496ca        hyperledger/fabric-orderer   "orderer"                36 minutes ago      Up 36 minutes       0.0.0.0:7050->7050/tcp                            fabric-orderer
71c2246e1165        hyperledger/fabric-ca        "fabric-ca server ..."   36 minutes ago      Up 36 minutes       7054/tcp, 0.0.0.0:8888->8888/tcp 
```

And will also generate a new chaincode image, name like `dev-peer0-test_cc-1.0`.
```bash
$ docker images
REPOSITORY                         TAG                             IMAGE ID            CREATED             SIZE
dev-peer0-test_cc-1.0              latest                          dd5ea867023e        36 minutes ago      874 MB
...
```

#### Query
Inside the container, query the existing value of `a` and `b`.

*Notice that the query method can be called by invoke a transaction.*

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode query -n test_cc -c '{"Args":["query","a"]}' -o orderer:7050
```

The final output may look like the following, with a payload value of `100`.

```bash
Query Result: 100
[main] main -> INFO 001 Exiting.....
```

Query the value of `b`

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode invoke -n test_cc -c '{"Args":["query","b"]}' -o orderer:7050
```

The final output may look like the following, with a payload value of `200`.

```bash
Query Result: 200
[main] main -> INFO 001 Exiting.....
```


#### Invoke
Inside the container, invoke a transaction to transfer `10` from `a` to `b`.

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode invoke -n test_cc -c '{"Args":["invoke","a","b","10"]}' -o orderer:7050
```

The final result may look like the following, the response should be `OK`.

```bash
[chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Invoke result: version:1 response:<status:200 message:"OK" > payload:"\n \215\263\337\322u\323?\242t$s\035l\270Ta\270\270+l6\322X\346\365k\020\215Phy\260\022C\n<\002\004lccc\001\007test_cc\004\001\001\001\001\000\000\007test_cc\002\001a\004\001\001\001\001\001b\004\001\001\001\001\002\001a\000\00290\001b\000\003210\000\032\003\010\310\001" endorsement:<endorser:"\n\007DEFAULT\022\232\007-----BEGIN -----\nMIICjDCCAjKgAwIBAgIUBEVwsSx0TmqdbzNwleNBBzoIT0wwCgYIKoZIzj0EAwIw\nfzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNh\nbiBGcmFuY2lzY28xHzAdBgNVBAoTFkludGVybmV0IFdpZGdldHMsIEluYy4xDDAK\nBgNVBAsTA1dXVzEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMTYxMTExMTcwNzAw\nWhcNMTcxMTExMTcwNzAwWjBjMQswCQYDVQQGEwJVUzEXMBUGA1UECBMOTm9ydGgg\nQ2Fyb2xpbmExEDAOBgNVBAcTB1JhbGVpZ2gxGzAZBgNVBAoTEkh5cGVybGVkZ2Vy\nIEZhYnJpYzEMMAoGA1UECxMDQ09QMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE\nHBuKsAO43hs4JGpFfiGMkB/xsILTsOvmN2WmwpsPHZNL6w8HWe3xCPQtdG/XJJvZ\n+C756KEsUBM3yw5PTfku8qOBpzCBpDAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYw\nFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFOFC\ndcUZ4es3ltiCgAVDoyLfVpPIMB8GA1UdIwQYMBaAFBdnQj2qnoI/xMUdn1vDmdG1\nnEgQMCUGA1UdEQQeMByCCm15aG9zdC5jb22CDnd3dy5teWhvc3QuY29tMAoGCCqG\nSM49BAMCA0gAMEUCIDf9Hbl4xn3z4EwNKmilM9lX2Fq4jWpAaRVB97OmVEeyAiEA\n25aDPQHGGq2AvhKT0wvt08cX1GTGCIbfmuLpMwKQj38=\n-----END -----\n" signature:"0E\002!\000\271\232\230\261\336\352ow\021V3\224\252\217\362vzM'\213\376@2\306/\201=\213\023\244\310%\002 \014\277\362|\223\342\277Pk5(\004\331\014\021\307\273\351/]:\020\232\013d\261\035+\266\265\305<" > 
[main] main -> INFO 002 Exiting.....
```

#### Query
Query again the existing value of `a` and `b`.

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode query -n test_cc -c '{"Args":["query","a"]}' -o orderer:7050
```
The new value of `a` should be 90.

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode query -n test_cc -c '{"Args":["query","b"]}' -o orderer:7050
```
The new value of `b` should be 210.

### Test chaincode with new channel (Optional)

#### Create new channel

Peers join channel `testchainid` by default. But if you want to use new channel, run the following command.
Create new channel named testchannel.

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer channel create -c testchannel -o orderer:7050
```
This will return a genesis block - testchannel.block.

#### Join the channel

Join peer0 to testchannel.
```bash
root@peer0:/go/src/github.com/hyperledger/fabric# CORE_PEER_ADDRESS=peer0:7051 peer channel join -b testchannel.block -o orderer:7050
```

The final result may look like following.

```bash
Join Result: 
[main] main -> INFO 001 Exiting.....
```

#### Deploy

First install a chaincode named test_cc to peer0 on channel testchannel:

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# CORE_PEER_ADDRESS=peer0:7051 peer chaincode install -C testchannel -n test_cc -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02  -v 1.0 -o orderer:7050
```

The result may look like following.

```bash
[golang-platform] writeGopathSrc -> INFO 001 rootDirectory = /go/src
[container] WriteFolderToTarPackage -> INFO 002 rootDirectory = /go/src
[main] main -> INFO 003 Exiting.....
```

Second instantiate chaincode test_cc:

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# CORE_PEER_ADDRESS=peer0:7051 peer chaincode instantiate -C testchannel -n test_cc -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -o orderer:7050
```

The result may look like following:

```bash
[chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
[chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
[main] main -> INFO 003 Exiting.....
```

#### Query

Query the existing value of `a` and `b`.

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# CORE_PEER_ADDRESS=peer0:7051 peer chaincode query -C testchannel -n test_cc -v 1.0 -c '{"Args":["query","a"]}' -o orderer:7050
```

The result may look like following, with a payload value of `100`.
```bash
Query Result: 100
[main] main -> INFO 001 Exiting.....
```

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# CORE_PEER_ADDRESS=peer0:7051 peer chaincode query -C testchannel -n test_cc -v 1.0 -c '{"Args":["query","b"]}' -o orderer:7050
```
The result may look like following, with a payload value of `200`.
```bash
Query Result: 200
[main] main -> INFO 001 Exiting.....
```


#### Invoke

Inside the container, invoke a transaction to transfer `10` from `a` to `b`.

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# CORE_PEER_ADDRESS=peer0:7051 peer chaincode invoke -C testchannel -n test_cc -v 1.0 -c '{"Args":["invoke","a","b","10"]}' -o orderer:7050
```

The result may look like following:

```bash
[chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Invoke result: version:1 response:<status:200 message:"OK" > payload:"\n L1sx\330\026\226\273\246\014\300\315\303\25501ED!\177\005!\003\312!\033\312\334\240\203y\024\022C\n<\002\004lccc\001\007test_cc\004\001\001\001\001\000\000\007test_cc\002\001a\004\001\001\001\001\001b\004\001\001\001\001\002\001a\000\00290\001b\000\003210\000\032\003\010\310\001" endorsement:<endorser:"\n\007DEFAULT\022\232\007-----BEGIN -----\nMIICjDCCAjKgAwIBAgIUBEVwsSx0TmqdbzNwleNBBzoIT0wwCgYIKoZIzj0EAwIw\nfzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNh\nbiBGcmFuY2lzY28xHzAdBgNVBAoTFkludGVybmV0IFdpZGdldHMsIEluYy4xDDAK\nBgNVBAsTA1dXVzEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMTYxMTExMTcwNzAw\nWhcNMTcxMTExMTcwNzAwWjBjMQswCQYDVQQGEwJVUzEXMBUGA1UECBMOTm9ydGgg\nQ2Fyb2xpbmExEDAOBgNVBAcTB1JhbGVpZ2gxGzAZBgNVBAoTEkh5cGVybGVkZ2Vy\nIEZhYnJpYzEMMAoGA1UECxMDQ09QMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE\nHBuKsAO43hs4JGpFfiGMkB/xsILTsOvmN2WmwpsPHZNL6w8HWe3xCPQtdG/XJJvZ\n+C756KEsUBM3yw5PTfku8qOBpzCBpDAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYw\nFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFOFC\ndcUZ4es3ltiCgAVDoyLfVpPIMB8GA1UdIwQYMBaAFBdnQj2qnoI/xMUdn1vDmdG1\nnEgQMCUGA1UdEQQeMByCCm15aG9zdC5jb22CDnd3dy5teWhvc3QuY29tMAoGCCqG\nSM49BAMCA0gAMEUCIDf9Hbl4xn3z4EwNKmilM9lX2Fq4jWpAaRVB97OmVEeyAiEA\n25aDPQHGGq2AvhKT0wvt08cX1GTGCIbfmuLpMwKQj38=\n-----END -----\n" signature:"0E\002!\000\306/\2643h\203\326\020x*g\246:E\270F\240<OCA\260\371\346\021\233\204\321Wv\tL\002 cu\241\034\341\316\374O`\332\224^j\354\233y\215\262|\306\303\353,'\332\230\214]R\327\343\024" > 
[main] main -> INFO 002 Exiting.....
```

#### Query

And then query the value of `a` and `b`.

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# CORE_PEER_ADDRESS=peer0:7051 peer chaincode query -C testchannel -n test_cc -v 1.0 -c '{"Args":["query","a"]}' -o orderer:7050
```

```bash
Query Result: 90
[main] main -> INFO 001 Exiting.....
```
The value of `a` should be `90`.

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# CORE_PEER_ADDRESS=peer0:7051 peer chaincode query -C testchannel -n test_cc -v 1.0 -c '{"Args":["query","b"]}' -o orderer:7050
```

The value of `b` should be `210`

```bash
Query Result: 210
[main] main -> INFO 001 Exiting.....
```

About this part of detailed context, [referenve linking](http://hyperledger-fabric.readthedocs.io/en/latest/asset_setup.html#asset-transfer-with-cli)

## Acknowledgement
* [Hyperledger Fabric](https://github.com/hyperledger/fabric/) project.