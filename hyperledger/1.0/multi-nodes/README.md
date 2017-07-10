[WIP]
### environment
```bash
peer0:      9.186.91.1/192.168.5.1
peer1:      9.186.91.2/192.168.5.2
peer2:      9.186.91.3/192.168.5.3
peer3:      9.186.91.4/192.168.5.4
orderer:    9.186.91.5/192.168.5.5
```

#### config /etc/hosts

In every node add following configurations in /etc/hots, But don't increase the node itself ip address.

```bash
192.168.5.1 peer0.org1.example.com
192.168.5.2 peer1.org1.example.com
192.168.5.3 peer0.org2.example.com
192.168.5.4 peer1.org2.example.com
192.168.5.5 orderer.example.com
```

Then test whether each nodes is connected.
 
 ```bash
 ping peer1.org1.example.com #in peer0
 ping peer0.org2.example.com
 ping peer1.org2.example.com
 ping orderer.example.com
 ```
 
### Start network 

First initialize nodes include create channel, join channel and install operations.

#### Orderer

In node orderer

```bash
$ cd ~/docker-compose-files/hyperledger/1.0/multi-nodes/orderer
$ (sduo) docker-compose -f multi-node-orderer.yaml up
````

#### peer0

In node peer0

```bash
$ cd ~/docker-compose-files/hyperledger/1.0/multi-nodes/peer0
$ (sduo) docker-compose -f multi-node-peer0.yaml up
$ bash ./scripts/initialize.sh
```

#### peer1

In node peer1

```bash
$ cd ~/docker-compose-files/hyperledger/1.0/multi-nodes/peer1
$ (sduo) docker-compose -f multi-node-peer1.yaml up
$ bash ./scripts/initialize.sh
```

#### peer2

In node peer2

```bash
$ cd ~/docker-compose-files/hyperledger/1.0/multi-nodes/peer2
$ (sduo) docker-compose -f multi-node-peer2.yaml up
$ bash ./scripts/initialize.sh
```

#### peer3

In node peer3

```bash
$ cd ~/docker-compose-files/hyperledger/1.0/multi-nodes/peer3
$ (sduo) docker-compose -f multi-node-peer3.yaml up
$ bash ./scripts/initialize.sh
```

After all nodes successful initialization, we will execute chaincode operations to check whether the network has started successfully.

#### Chiancode

In peer0-peer3 execute the following commands in turn:

```bash
$ docker exec -it fabric-cli bash
$ bash ./scripts/chaincode-operation.sh
```