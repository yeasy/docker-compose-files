## Detailed Steps

### Environment Setup

The following scripts will setup the environment by installing Docker, Docker-Compose and download required docker images. 

```sh
$ make setup # setup environment
```

If you want to setup the environment manually, then have a look at [manually setup](docs/setup.md).

### Generate crypto-config and channel-artifacts

```bash
$ make gen_config
``` 

The cmd actually calls `scripts/gen_config.sh` to generate the `crypto-config` and `channel-artifacts`. 

More details can be found at [Config Generation](docs/config_generation.md).

### Bootup Fabric Network

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

### Create Application Channel

```bash
$ make test_channel_create 
```

The command actually calls the `scripts/test_channel_create.sh` script in the `fabric-cli` container, to create a new application channel with default name of `businesschannel`.


### Join Peers into Application Channel

```bash
$ make test_channel_join 
```

The command actually calls the `scripts/test_channel_join.sh` script in the `fabric-cli` container,  to join all peers into the channel.

### Intall Chaincode to All Peers

```bash
$ make test_cc_install
```

The command actually calls the `scripts/test_cc_install.sh` script in the `fabric-cli` container, to install chaincode `example02` for testing.

### Instantiate Chaincode in the Application Channel

```bash
$ make test_cc_instantiate
```

The command actually calls the `scripts/test_cc_instantiate.sh` script in the `fabric-cli` container, to instantiate chaincode `example02`.

And there will be new chaincode container generated in the system, looks like

```bash
$ make ps
CONTAINER ID        IMAGE                                 COMMAND                  CREATED              STATUS              PORTS                                                                                                NAMES
9971c9fd1971        dev-peer1.org2.example.com-mycc-1.0   "chaincode -peer.a..."   54 seconds ago       Up 53 seconds                                                                                                            dev-peer1.org2.example.com-mycc-1.0
e3092961b81b        dev-peer1.org1.example.com-mycc-1.0   "chaincode -peer.a..."   About a minute ago   Up About a minute                                                                                                        dev-peer1.org1.example.com-mycc-1.0
57d3555f56e5        dev-peer0.org2.example.com-mycc-1.0   "chaincode -peer.a..."   About a minute ago   Up About a minute                                                                                                        dev-peer0.org2.example.com-mycc-1.0
c9974dbc21d9        dev-peer0.org1.example.com-mycc-1.0   "chaincode -peer.a..."   23 minutes ago       Up 23 minutes                                                                                                            dev-peer0.org1.example.com-mycc-1.0
```
### Test Chaincode

```bash
$ make test_cc_invoke_query
```

The command actually calls the `scripts/test_cc_invoke_query.sh` script in the `fabric-cli` container, to test chaincode `example02` with invoke and query.

### Test System Chaincode

```bash
$ make test_lscc # test LSCC
$ make test_qscc # test QSCC
```

The command actually calls the `scripts/test_lscc.sh` and `scripts/test_qscc.sh` script in the `fabric-cli` container, to test LSCC and QSCC.

### Test Fetch Blocks

```bash
$ make test_fetch_blocks # test fetch blocks
```

The command actually calls the `scripts/test_fetch_blocks.sh` script in the `fabric-cli` container, to test fetching blocks from channels.

### Test Configtxlator

```bash
$ make test_configtxlator
```

The command actually calls the `scripts/test_configtxlator.sh` script in the `fabric-cli` container, to test configtxlator to change the channel configuration.

More details can be found at [Configtxlator](docs/configtxlator.md).

### Stop the network

```bash
$ make stop # stop the fabric network
```

### Clean environment

Clean all related containers and images.

```bash
$ make clean # clean the environment
```


### Enable Event Listener

See [Event Listener](docs/event_listener.md).

### More to learn

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


