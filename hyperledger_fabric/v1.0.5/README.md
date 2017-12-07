# Hyperledger fabric 1.0.4

Here we show steps on how to setup a fabric 1.0.4 network on Linux (e.g., Ubuntu/Debian), and then use it to run chaincode tests.

If you're not familiar with Docker and Blockchain technology yet, feel free to have a look at 2 books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)


## Pass-through

The following command will run the entire process (start a fabric network, create channel, test chaincode and stop it.) pass-through.

```sh
$ make setup # install docker/compose, and pull required images
$ make all
```

tldr :)

`make all` actually call following command sequentially.

* `make start`
* `make init`
* `make test_cc`
* `make stop`

Otherwise, if u wanna know more or run the command manually, then go on reading the following part.

## Environment Setup

The following scripts will setup the environment by installing Docker, Docker-Compose and download required docker images. 

```sh
$ make setup # setup environment
```

If you want to setup the environment manually, then have a look at [manually setup](docs/setup.md).

## Bootup Fabric Network

Start a 4 peer (belonging to 2 organizations) fabric network.

```sh
$ make start  # Start a fabric network
```
The script actually uses docker-compose to boot up the fabric network with several containers.

There will be 7 running containers, include 4 peers, 1 cli, 1 ca and 1 orderer.

```bash
$ make ps
CONTAINER ID        IMAGE                                     COMMAND                  CREATED             STATUS              PORTS                                                                                                NAMES
f6686986fe18        hyperledger/fabric-tools:x86_64-1.0.4     "bash -c 'cd /tmp;..."   6 seconds ago       Up 14 seconds                                                                                                            fabric-cli
c7f274bf60bc        yeasy/hyperledger-fabric-peer:1.0.4       "peer node start"        6 seconds ago       Up 11 seconds       7050/tcp, 7054-7059/tcp, 0.0.0.0:10051->7051/tcp, 0.0.0.0:10052->7052/tcp, 0.0.0.0:10053->7053/tcp   peer1.org2.example.com
c6c5f69f2d53        yeasy/hyperledger-fabric-peer:1.0.4       "peer node start"        6 seconds ago       Up 12 seconds       7050/tcp, 7054-7059/tcp, 0.0.0.0:8051->7051/tcp, 0.0.0.0:8052->7052/tcp, 0.0.0.0:8053->7053/tcp      peer1.org1.example.com
3cad0c519e6f        yeasy/hyperledger-fabric-peer:1.0.4       "peer node start"        6 seconds ago       Up 13 seconds       7050/tcp, 7054-7059/tcp, 0.0.0.0:7051-7053->7051-7053/tcp                                            peer0.org1.example.com
8b371209f6b8        yeasy/hyperledger-fabric-peer:1.0.4       "peer node start"        6 seconds ago       Up 11 seconds       7050/tcp, 7054-7059/tcp, 0.0.0.0:9051->7051/tcp, 0.0.0.0:9052->7052/tcp, 0.0.0.0:9053->7053/tcp      peer0.org2.example.com
ba1f00a9c83c        hyperledger/fabric-orderer:x86_64-1.0.4   "orderer start"          6 seconds ago       Up 14 seconds       0.0.0.0:7050->7050/tcp                                                                               orderer.example.com
```

### Initialize Fabric network

```bash
$ make init  # Start a fabric network
```

The command actually calls the `./scripts/initialize.sh` script in the `fabric-cli` container to:

* create a new application channel `businesschannel`
* join all peers into the channel
* install and instantiate chaincode `example02` for testing

This script only needs to be executed once.

You should see result like the following if the initialization is successful.

```bash
==============================================
==========initialize businesschannel==========
==============================================

Channel name: businesschannel
Creating channel...

...

===================== All GOOD, initialization completed ===================== 
```

And there will be new chaincode container generated in the system, looks like

```bash
$ make ps
CONTAINER ID        IMAGE                                 COMMAND                  CREATED              STATUS              PORTS                                                                                                NAMES
9971c9fd1971        dev-peer1.org2.example.com-mycc-1.0   "chaincode -peer.a..."   54 seconds ago       Up 53 seconds                                                                                                            dev-peer1.org2.example.com-mycc-1.0
e3092961b81b        dev-peer1.org1.example.com-mycc-1.0   "chaincode -peer.a..."   About a minute ago   Up About a minute                                                                                                        dev-peer1.org1.example.com-mycc-1.0
57d3555f56e5        dev-peer0.org2.example.com-mycc-1.0   "chaincode -peer.a..."   About a minute ago   Up About a minute                                                                                                        dev-peer0.org2.example.com-mycc-1.0
c9974dbc21d9        dev-peer0.org1.example.com-mycc-1.0   "chaincode -peer.a..."   23 minutes ago       Up 23 minutes                                                                                                            dev-peer0.org1.example.com-mycc-1.0
```


## Test Chaincode

```bash
$ make test_cc # test invoke and query with chaincode
```

More details, see [chaincode test](docs/chaincode_test.md).


## Stop the network

```bash
$ make stop # stop the fabric network
```

## Clean environment

Clean all related containers and images.

```bash
$ make clean # clean the environment
```

## More to learn

Topics | Description
-- | -- 
[Detailed Explanation](./docs/detailed_steps.md) | Explain in detail how a 1-peer network start and test.
[Fetch blocks](docs/peer_cmds.md) | Fetch blocks using `peer channel fetch` cmd.
[Use Events](./docs/events.md) | Get events with block-listener
[Artifacts Generation](docs/artifacts_generation.md) | Will explain the usage of `cryptogen` and `configtxgen` to prepare the artifacts for booting the fabric network.
[couchDB](docs/couchdb_usage.md) | Use couchDB as the state DB.
[kafka](./kafka/README.md) | Use kafka as the ordering backend
[configtxlator](docs/configtxlator.md) | Use configtxlator to convert the configurations
[WIP] [Some verification tests](docs/verification_test.md) | 


## Acknowledgement
* [Hyperledger Fabric](https://github.com/hyperledger/fabric/) project.
* [Hyperledger Fabric Getting Started](http://hyperledger-fabric.readthedocs.io/en/latest/getting_started.html).
