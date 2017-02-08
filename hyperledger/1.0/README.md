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
$ docker pull yeasy/hyperledger-fabric-base:latest \
  && docker pull yeasy/hyperledger-fabric-peer:latest \
  && docker pull yeasy/hyperledger-fabric-orderer:latest \
  && docker pull yeasy/hyperledger-fabric-ca:latest \
  && docker pull yeasy/blockchain-explorer:latest \
  && docker tag yeasy/hyperledger-fabric-peer hyperledger/fabric-peer \
  && docker tag yeasy/hyperledger-fabric-orderer hyperledger/fabric-orderer \
  && docker tag yeasy/hyperledger-fabric-ca hyperledger/fabric-ca \
  && docker tag yeasy/hyperledger-fabric-base hyperledger/fabric-baseimage \
  && docker tag yeasy/hyperledger-fabric-base hyperledger/fabric-ccenv:x86_64-1.0.0-snapshot-preview
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

Start a MVE fabric cluster.

```sh
$ docker-compose up
```

Check the output log that the peer is connected to the ca and orderer successfully.

There will be 3 running containers.

```bash
$ docker ps -a
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                                             NAMES
069427b04bfa        hyperledger/fabric-peer      "peer node start"        5 minutes ago       Up 5 minutes        7050/tcp, 7052-7059/tcp, 0.0.0.0:7051->7051/tcp   fabric-peer0
d22c541c68f5        hyperledger/fabric-orderer   "orderer"                5 minutes ago       Up 5 minutes        0.0.0.0:7050->7050/tcp                            fabric-orderer
ca046fc3c0e7        hyperledger/fabric-ca       "ca server start -ca"   5 minutes ago       Up 5 minutes        0.0.0.0:8888->8888/tcp                            fabric-ca
```

### Test chaincode

After the cluster is synced successfully, you can validate by deploying, invoking or querying chaincode from the container or from the host.

#### Deploy
Use `docker exec -it fabric-peer0 bash` to open a bash inside container `fabric-peer0`, which will accept our chaincode testing commands of `deploy`, `invoke` and `query`.

Inside the container, run the following command to deploy a new chaincode of the example02. The chaincode will initialize two accounts: `a` and `b`, with value of `100` and `200`.

```bash
$ docker exec -it fabric-peer0 bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode deploy -n test_cc -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -c '{"Args":["init","a","100","b","200"]}'
```

There should be no error in the return log, and in the peer nodes's output.

Wait several seconds till the deploy is finished.

#### Query
Inside the container, query the existing value of `a` and `b`.

*Notice that the query method is called by invoke a transaction.*

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode invoke -n test_cc -c '{"Args":["query","a"]}'
```

The final output may look like the following, with a payload value of `100`.

```bash
[chaincodeCmd] chaincodeInvokeOrQuery -> INFO 025 Invoke result: version:1 response:<status:200 message:"OK" payload:"100" > payload:"\n M\357\236W\346\363W\320\\#[6H\246s\273\2270<3\253\340i\311i\371i\341\0143\301?\022(\n&\002\004lccc\001\007test_cc\004\001\001\001\001\000\007test_cc\001\001a\004\001\001\001\001\000" endorsement:<endorser:"\n\007DEFAULT\022\232\007-----BEGIN -----\nMIICjDCCAjKgAwIBAgIUBEVwsSx0TmqdbzNwleNBBzoIT0wwCgYIKoZIzj0EAwIw\nfzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNh\nbiBGcmFuY2lzY28xHzAdBgNVBAoTFkludGVybmV0IFdpZGdldHMsIEluYy4xDDAK\nBgNVBAsTA1dXVzEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMTYxMTExMTcwNzAw\nWhcNMTcxMTExMTcwNzAwWjBjMQswCQYDVQQGEwJVUzEXMBUGA1UECBMOTm9ydGgg\nQ2Fyb2xpbmExEDAOBgNVBAcTB1JhbGVpZ2gxGzAZBgNVBAoTEkh5cGVybGVkZ2Vy\nIEZhYnJpYzEMMAoGA1UECxMDQ09QMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE\nHBuKsAO43hs4JGpFfiGMkB/xsILTsOvmN2WmwpsPHZNL6w8HWe3xCPQtdG/XJJvZ\n+C756KEsUBM3yw5PTfku8qOBpzCBpDAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYw\nFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFOFC\ndcUZ4es3ltiCgAVDoyLfVpPIMB8GA1UdIwQYMBaAFBdnQj2qnoI/xMUdn1vDmdG1\nnEgQMCUGA1UdEQQeMByCCm15aG9zdC5jb22CDnd3dy5teWhvc3QuY29tMAoGCCqG\nSM49BAMCA0gAMEUCIDf9Hbl4xn3z4EwNKmilM9lX2Fq4jWpAaRVB97OmVEeyAiEA\n25aDPQHGGq2AvhKT0wvt08cX1GTGCIbfmuLpMwKQj38=\n-----END -----\n" signature:"0E\002 +\223\213\026\025\006|H\300\205\362\345\251\373a\241\241\373\360H\032'&\223#\035W\354\032\0321\214\002!\000\351y\027\220\351\317\342\235\255\266zqfO\305\207\346\314\256\005L\025\244A\361-\241>~h\307\"" >
```

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode invoke -n test_cc -c '{"Args":["query","b"]}'
```

The final output may look like the following, with a payload value of `200`.

```bash
[chaincodeCmd] chaincodeInvokeOrQuery -> INFO 025 Invoke result: version:1 response:<status:200 message:"OK" payload:"200" > payload:"\n \237K\000W\360\374\207\210\201PF\220\222 8-\220\223\257\373\\\272\231c\3622\306\332\356\246\346\300\022(\n&\002\007test_cc\001\001b\004\001\001\001\001\000\004lccc\001\007test_cc\004\001\001\001\001\000" endorsement:<endorser:"\n\007DEFAULT\022\232\007-----BEGIN -----\nMIICjDCCAjKgAwIBAgIUBEVwsSx0TmqdbzNwleNBBzoIT0wwCgYIKoZIzj0EAwIw\nfzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNh\nbiBGcmFuY2lzY28xHzAdBgNVBAoTFkludGVybmV0IFdpZGdldHMsIEluYy4xDDAK\nBgNVBAsTA1dXVzEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMTYxMTExMTcwNzAw\nWhcNMTcxMTExMTcwNzAwWjBjMQswCQYDVQQGEwJVUzEXMBUGA1UECBMOTm9ydGgg\nQ2Fyb2xpbmExEDAOBgNVBAcTB1JhbGVpZ2gxGzAZBgNVBAoTEkh5cGVybGVkZ2Vy\nIEZhYnJpYzEMMAoGA1UECxMDQ09QMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE\nHBuKsAO43hs4JGpFfiGMkB/xsILTsOvmN2WmwpsPHZNL6w8HWe3xCPQtdG/XJJvZ\n+C756KEsUBM3yw5PTfku8qOBpzCBpDAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYw\nFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFOFC\ndcUZ4es3ltiCgAVDoyLfVpPIMB8GA1UdIwQYMBaAFBdnQj2qnoI/xMUdn1vDmdG1\nnEgQMCUGA1UdEQQeMByCCm15aG9zdC5jb22CDnd3dy5teWhvc3QuY29tMAoGCCqG\nSM49BAMCA0gAMEUCIDf9Hbl4xn3z4EwNKmilM9lX2Fq4jWpAaRVB97OmVEeyAiEA\n25aDPQHGGq2AvhKT0wvt08cX1GTGCIbfmuLpMwKQj38=\n-----END -----\n" signature:"0E\002!\000\372\223\021\305\032\351L\362`?\\\274\233\334\332\374\250,H\"vq~\226^\2707W\300\207D8\002 \034\031/$&\360<iI\372\323\017\352QTwH\263\217\003E\312\306\020\036\225\026\0103^a\307" >
```

After query, there will generate a new chaincode container, besides the 3 existing one.

```bash
$ docker ps
CONTAINER ID        IMAGE                                                                                                                                                COMMAND                  CREATED              STATUS              PORTS                                             NAMES
f03e586db8c5        dev-peer0-test_cc-0-48baa00e355e6db1648cff44e28f1dbf322523a99ffe283fd99a00348466eb78075559488e372409bb691aab29cfa894645c9c2737781367012e0c816eb227b7   "/opt/gopath/bin/test"   About a minute ago   Up About a minute                                                     dev-peer0-test_cc-0-48baa00e355e6db1648cff44e28f1dbf322523a99ffe283fd99a00348466eb78075559488e372409bb691aab29cfa894645c9c2737781367012e0c816eb227b7
069427b04bfa        hyperledger/fabric-peer                                                                                                                              "peer node start"        9 minutes ago        Up 9 minutes        7050/tcp, 7052-7059/tcp, 0.0.0.0:7051->7051/tcp   fabric-peer0
d22c541c68f5        hyperledger/fabric-orderer                                                                                                                           "orderer"                9 minutes ago        Up 9 minutes        0.0.0.0:7050->7050/tcp                            fabric-orderer
ca046fc3c0e7        hyperledger/fabric-ca                                                                                                                               "ca server start -ca"   9 minutes ago        Up 9 minutes        0.0.0.0:8888->8888/tcp                            fabric-ca
```

#### Invoke
Inside the container, invoke a transaction to transfer `10` from `a` to `b`.

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode invoke -n test_cc -c '{"Args":["invoke","a","b","10"]}'
```

The final result may look like the following, the response should be `OK`.

```bash
[chaincodeCmd] chaincodeInvokeOrQuery -> INFO 025 Invoke result: version:1 response:<status:200 message:"OK" > payload:"\n I\225\305\002\232&\241N\031wQ\002\304Q\332H\247\330f\271\216Pp\311\254\314\226\255\277\031\325H\022<\n:\002\004lccc\001\007test_cc\004\001\001\001\001\000\007test_cc\002\001a\004\001\001\001\001\001b\004\001\001\001\001\002\001b\000\003210\001a\000\00290" endorsement:<endorser:"\n\007DEFAULT\022\232\007-----BEGIN -----\nMIICjDCCAjKgAwIBAgIUBEVwsSx0TmqdbzNwleNBBzoIT0wwCgYIKoZIzj0EAwIw\nfzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNh\nbiBGcmFuY2lzY28xHzAdBgNVBAoTFkludGVybmV0IFdpZGdldHMsIEluYy4xDDAK\nBgNVBAsTA1dXVzEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMTYxMTExMTcwNzAw\nWhcNMTcxMTExMTcwNzAwWjBjMQswCQYDVQQGEwJVUzEXMBUGA1UECBMOTm9ydGgg\nQ2Fyb2xpbmExEDAOBgNVBAcTB1JhbGVpZ2gxGzAZBgNVBAoTEkh5cGVybGVkZ2Vy\nIEZhYnJpYzEMMAoGA1UECxMDQ09QMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE\nHBuKsAO43hs4JGpFfiGMkB/xsILTsOvmN2WmwpsPHZNL6w8HWe3xCPQtdG/XJJvZ\n+C756KEsUBM3yw5PTfku8qOBpzCBpDAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYw\nFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFOFC\ndcUZ4es3ltiCgAVDoyLfVpPIMB8GA1UdIwQYMBaAFBdnQj2qnoI/xMUdn1vDmdG1\nnEgQMCUGA1UdEQQeMByCCm15aG9zdC5jb22CDnd3dy5teWhvc3QuY29tMAoGCCqG\nSM49BAMCA0gAMEUCIDf9Hbl4xn3z4EwNKmilM9lX2Fq4jWpAaRVB97OmVEeyAiEA\n25aDPQHGGq2AvhKT0wvt08cX1GTGCIbfmuLpMwKQj38=\n-----END -----\n" signature:"0E\002 h\260\3062\022\315\016\345\032C\002W\361\366\313\366\225\002\300\250\017\0047\314\361P\270\261\330\226\371\006\002!\000\376\331\222JI\026\026\347\010Y73\334}\321\311\236\265\325'\"\317\311:l\\\025\240\334\2073\202" >
```

#### Query
Query again the existing value of `a` and `b`.

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode invoke -n test_cc -c '{"Args":["query","a"]}'
```
The new value of `a` should be 90.

```bash
root@peer0:/go/src/github.com/hyperledger/fabric# peer chaincode invoke -n test_cc -c '{"Args":["query","a"]}'
```
The new value of `b` should be 210.

## Acknowledgement
* [Hyperledger Fabric](https://github.com/hyperledger/fabric/) project.
