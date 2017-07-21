# Hyperledger fabric 1.0

Here we show steps on how to setup a fabric 1.0 network, and then use it to run chaincode tests.

If you're not familiar with Docker and Blockchain technology yet, feel free to have a look at 2 books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)

## Environment Setup

tldr :)

With Linxu (e.g., Ubuntu/Debian) and MacOS, you can simple use the following scripts to setup the environment and start a 4 peer (belonging to 2 organizations) fabric network.

```sh
$ bash scripts/setup_Docker.sh  # Install Docker, Docker-Compose 
  bash scripts/download_images.sh  # Pull required Docker images
  bash scripts/start_fabric.sh
```

If you want to setup the environment manually, then have a look at [manually setup](docs/setup.md).



## More to explore

### [Explain the steps](./docs/docker-compose-1peer-usage.md)

Explain in detail how a 1-peer network start and test


### [Fetch blocks](./docs/peer-command-usage.md)

Fetch blocks using peer channel fetch


### [Events](./docs/events.md)

Get events with block-listener


### [Tool usage](./artifacts_generation/artifacts_generation.md)

Will explain the usage of `cryptogen` and `configtxgen`

### [Use database couchDB](./docs/couchdb-usage.md)

### [kafka](./kafka/README.md)

### [configtxlator](./docs/configtxlator-usage.md)

### [WIP] [Some verification tests](./docs/Verification-test.md)
=======


## Acknowledgement
* [Hyperledger Fabric](https://github.com/hyperledger/fabric/) project.
* [Hyperledger Fabric Getting Started](http://hyperledger-fabric.readthedocs.io/en/latest/getting_started.html).
