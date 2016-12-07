# Hyperledger fabric

You can use the following script to install Docker and start a 4-node PBFT cluster in one instruction.

```sh
$ bash setupPbft.sh
```

## Preparation

### Download Images

*The latest code is evolving quickly, we recommend to use the 0.6 branch code currently.*

Pull necessary images of peer, base image and the membersrvc.

```sh
$ docker pull yeasy/hyperledger-fabric:0.6-dp
$ docker tag yeasy/hyperledger-fabric:0.6-dp hyperledger/fabric-peer:latest
$ docker tag yeasy/hyperledger-fabric:0.6-dp hyperledger/fabric-baseimage:latest
$ docker tag yeasy/hyperledger-fabric:0.6-dp hyperledger/fabric-membersrvc:latest
```

The community [images](https://hub.docker.com/r/hyperledger/) are also available at dockerhub, use at your own choice.

### Setup network

*Just ignore if you are not familiar with Docker networking configurations.*

The template can support using separate network for the chain.

By default, the feature is disabled to use the shared Docker network.

If you want to enable the feature, just uncommend the networks section at the bottom, and create the following two Docker networks.

```sh
$ docker network create fabric_noops
$ docker network create fabric_pbft
```

## Usage

### 4-node Noops

Start a 4-node fabric cluster with Noops consensus.

```sh
$ cd noops; docker-compose up
```

### 4-node PBFT

Start a 4-node fabric cluster with PBFT consensus.

```sh
$ cd pbft; docker-compose up
```

### Test chaincode

After the cluster is synced successfully, you can validate by deploying, invoking or querying chaincode from the container or from the host.

```sh
$ docker exec -it pbft_vp0_1 bash
# peer chaincode deploy -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -c '{"Function":"init", "Args": ["a","100", "b", "200"]}'
```

See [hyperledger-fabric](https://github.com/yeasy/docker-hyperledger-fabric) if you've not familiar on those operations.


### 4-node PBFT with blockchain-explorer

Start a 4-node fabric cluster with PBFT consensus and with blockchain-explorer as the dashboard.

```sh
$ cd pbft; docker-compose -f docker-compose-with-explorer.yml up
```

Then visit the `localhost:9090` on the host using Web.

### 4-node PBFT with member service

Start a 4-node fabric cluster with PBFT consensus and with member service.

```sh
$ cd pbft; docker-compose -f docker-compose-with-membersrvc.yml up
```

Then go to vp0, login and deploy a chaincode.

```sh
$ docker exec -it pbft_vp0_1 bash
# peer network login jim
08:23:13.604 [networkCmd] networkLogin -> INFO 001 CLI client login...
08:23:13.604 [networkCmd] networkLogin -> INFO 002 Local data store for client loginToken: /var/hyperledger/production/client/
Enter password for user 'jim': 6avZQLwcUe9b
...

# peer chaincode deploy -u jim -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -c '{"Function":"init", "Args": ["a","100", "b", "200"]}'
```

4 new chaincode containers will be built up automatically.

## Acknowledgement
This refers the example from the [hyperledger](https://github.com/hyperledger/fabric/tree/master/consensus/docker-compose-files) project.
