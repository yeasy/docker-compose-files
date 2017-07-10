[WIP]

## Start a network base on kafka

```bash
$ docker-compose -f orderer-kafka.yaml up
```

### Chaincode

```bash
$ docker exec -it fabric-cli bash
$ bash ./scripts/initialize.sh
$ bash ./scripts/test_4peers.sh
```
