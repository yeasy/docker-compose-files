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


### Bootup and test Fabric 1.0

Start a  fabric cluster.

```bash
$ bash scripts/start_fabric.sh
```

or

```sh
$ docker-compose -f docker-compose-2orgs-4peers.yaml up
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

#### Initialize fabric network

Into the container fabric-cli and run the initialize.sh script, this will prepare the basic environment required for chaincode operations,
inclode `create channel`, `join channel`, `install` and `instantiate`. this script only needs to be executed once.


```bash
$ docker exec -it fabric-cli bash
$ bash ./scripts/initialize.sh
```

You should see the following output:

```bash
2017-06-09 10:13:01.015 UTC [main] main -> INFO 00c Exiting.....
===================== Chaincode Instantiation on PEER2 on channel 'businesschannel' is successful ===================== 


===================== All GOOD, initialization completed ===================== 


 _____   _   _   ____  
| ____| | \ | | |  _ \ 
|  _|   |  \| | | | | |
| |___  | |\  | | |_| |
|_____| |_| \_| |____/ 
```

#### Chaincode operation

After initialize network, you can execute some chaincode operations, such as `query` or `invoke`,
and you can modify the parameters and execute this script repeatedly.

```bash
$ bash ./scripts/test_4peers.sh  #execute in container fabric-cli
```

You should see the following output:

```bash
UTC [msp] GetLocalMSP -> DEBU 004 Returning existing local MSP
UTC [msp] GetDefaultSigningIdentity -> DEBU 005 Obtaining default signing identity
UTC [msp/identity] Sign -> DEBU 006 Sign: plaintext: 0AB7070A6D08031A0C08C3EAE9C90510...6D7963631A0A0A0571756572790A0161 
UTC [msp/identity] Sign -> DEBU 007 Sign: digest: FA308EF50C4812BADB60D58CE15C1CF41089EFB93B27D46885D92C92F55E98A0 
Query Result: 80
UTC [main] main -> INFO 008 Exiting.....
===================== Query on PEER3 on channel 'businesschannel' is successful ===================== 

===================== All GOOD, End-2-End execution completed ===================== 


 _____   _   _   ____  
| ____| | \ | | |  _ \ 
|  _|   |  \| | | | | |
| |___  | |\  | | |_| |
|_____| |_| \_| |____/ 
```

So far, we have quickly started a fabric network successfully.

## Expand

### [Explain the steps](./docs/docker-compose-1peer-usage.md)

Explain in detail how a 1-peer network start and test


### [Fetch blocks](./docs/peer-command-usage.md)

Fetch blocks using peer channel fetch


### [Events](./docs/events.md)

Get events with block-listener


### [Tool usage](./artifacts_generation/artifacts_generation.md)

Will explain the usage of `cryptogen` and `configtxgen`


### [WIP] [Some verification tests](./docs/Verification-test.md)


### [Use database couchDB](./docs/couchdb-usage.md)

### [WIP] [kafka usage](./docs/kafka-usage.md)


## Acknowledgement
* [Hyperledger Fabric](https://github.com/hyperledger/fabric/) project.
* [Hyperledger Fabric Getting Started](http://hyperledger-fabric.readthedocs.io/en/latest/getting_started.html).
