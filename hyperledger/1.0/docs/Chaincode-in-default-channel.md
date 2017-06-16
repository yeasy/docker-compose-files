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