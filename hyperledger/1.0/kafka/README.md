[WIP]

## Start a network base on kafka

```bash
$ cd ~/docker-compose-files/tree/master/hyperledger/1.0/kafka
$ docker-compose -f orderer-kafka.yaml up (-d)
```
When the fabric-network fully started, it takes about 15-20s. 

## Test chaincode

```bash
$ docker exec -it fabric-cli bash
$ bash ./scripts/initialize.sh # initialize the fabric network
$ bash ./scripts/test_4peers.sh
```

>(Optional) If you want to use official images, you can run the following command first
>
> ```bash
> $ cd ~/docker-compose-files/tree/master/hyperledger/1.0
> $ bash ./scripts/download_official_images.sh
> ```
