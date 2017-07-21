## Manually Setup


### Install Docker/Docker-Compose

```sh
$ bash scripts/setup_Docker.sh  # Install Docker, Docker-Compose 
```

### Download Images

Pull necessary images of peer, orderer, ca, and base image. You may optionally run the clean_env.sh script to remove all existing container and images.

```sh
$ bash scripts/cleanup_env.sh
$ bash scripts/download_images.sh
```

There are also some community [images](https://hub.docker.com/r/hyperledger/) at Dockerhub, use at your own choice.


### Bootup Fabric Network

Start a fabric network with 4 peers belongs to 2 organizations.

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

Now you can try chaincode operations with the bootup fabric network.