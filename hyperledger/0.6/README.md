# Hyperledger fabric

You can use the following script to install Docker and start a 4-node PBFT cluster in one instruction.

```sh
$ bash setupPbft.sh
```

tldr :)

If you want to explore more, then can follow these steps.

If you're not familiar with Docker and Blockchain, can have a look at 2 books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)

## Preparation

### Download Images

*The latest code is evolving quickly, we recommend to use the 0.6 branch code currently.*

Pull necessary images of peer, base image and the membersrvc. You can use any one from below options

#### Option 1: Use community images
The community [images](https://hub.docker.com/r/hyperledger/) are available at dockerhub, use at your own choice.

```bash
$ docker pull hyperledger/fabric-peer:x86_64-0.6.1-preview \
  && docker pull hyperledger/fabric-membersrvc:x86_64-0.6.1-preview \
  && docker pull yeasy/blockchain-explorer:latest \
  && docker tag hyperledger/fabric-peer:x86_64-0.6.1-preview hyperledger/fabric-peer \
  && docker tag hyperledger/fabric-peer:x86_64-0.6.1-preview hyperledger/fabric-baseimage \
  && docker tag hyperledger/fabric-membersrvc:x86_64-0.6.1-preview hyperledger/fabric-membersrvc
```

#### Option 2: Use IBM certificated images
IBM also provides some tested [images](http://www-31.ibm.com/ibm/cn/blockchain/index.html), available at [dockerhub](http://www-31.ibm.com/ibm/cn/blockchain/index.html), use at your own choice.

```bash
$ docker pull ibmblockchain/fabric-peer:x86_64-0.6.1-preview \
  && docker pull ibmblockchain/fabric-membersrvc:x86_64-0.6.1-preview \
  && docker pull yeasy/blockchain-explorer:latest \
  && docker tag ibmblockchain/fabric-peer:x86_64-0.6.1-preview hyperledger/fabric-peer \
  && docker tag ibmblockchain/fabric-peer:x86_64-0.6.1-preview hyperledger/fabric-baseimage \
  && docker tag ibmblockchain/fabric-membersrvc:x86_64-0.6.1-preview hyperledger/fabric-membersrvc
```
#### Option 3: Use my images

Some tested dockerhub image with latest changes, Dockerfile provided.

```sh
$ docker pull yeasy/hyperledger-fabric-base:0.6-dp \
  && docker pull yeasy/hyperledger-fabric-peer:0.6-dp \
  && docker pull yeasy/hyperledger-fabric-membersrvc:0.6-dp \
  && docker pull yeasy/blockchain-explorer:latest \
  && docker tag yeasy/hyperledger-fabric-peer:0.6-dp hyperledger/fabric-peer \
  && docker tag yeasy/hyperledger-fabric-base:0.6-dp hyperledger/fabric-baseimage \
  && docker tag yeasy/hyperledger-fabric-membersrvc:0.6-dp hyperledger/fabric-membersrvc
```


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

When use the 0.6 branch, first switch to `0.6` directory.

```bash
$ cd 0.6
```

### 4-node Noops

Start a 4-node fabric cluster with Noops consensus.

```sh
$ cd noops; docker-compose -f 4-peers.yml up
```

### 4-node PBFT

Start a 4-node fabric cluster with PBFT consensus.

```sh
$ cd pbft; docker-compose -f 4-peers.yml up
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
$ cd pbft; docker-compose -f 4-peers-with-explorer.yml up
```

Then visit the `localhost:9090` on the host using Web.

### 4-node PBFT with member service

Start a 4-node fabric cluster with PBFT consensus and with member service.

```sh
$ cd pbft; docker-compose -f 4-peers-with-membersrvc.yml up
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
This refers the example from the [hyperledger](https://github.com/hyperledger/fabric/tree/master/consensus/4-peers-files) project.
