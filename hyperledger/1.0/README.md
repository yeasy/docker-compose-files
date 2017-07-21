# Hyperledger fabric 1.0

Here we show steps on how to setup a fabric 1.0 network on Linux (e.g., Ubuntu/Debian), and then use it to run chaincode tests.

If you're not familiar with Docker and Blockchain technology yet, feel free to have a look at 2 books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)

## Setup

tldr :)

The following scripts will setup the environment and start a 4 peer (belonging to 2 organizations) fabric network.

```sh
$ bash scripts/setup_Docker.sh  # Install Docker, Docker-Compose 
  bash scripts/download_images.sh  # Pull required Docker images
  bash scripts/start_fabric.sh
```

If you want to setup the environment manually, then have a look at [manually setup](docs/setup.md).

## Test Chaincode

See [chaincode test](docs/chaincode_test.md).

## More to learn

Topics | Description
-- | -- 
[Detailed Explanation](./docs/detailed_steps.md) | Explain in detail how a 1-peer network start and test.
[Fetch blocks](docs/peer_cmds.md) | Fetch blocks using `peer channel fetch` cmd.
[Use Events](./docs/events.md) | Get events with block-listener
[Artifacts Generation](docs/artifacts_generation.md) | Will explain the usage of `cryptogen` and `configtxgen` to prepare the artifacts for booting the fabric network.
[couchDB](docs/couchdb_usage.md) | Use couchDB as the state DB.
[kafka](./kafka/README.md) | Use kafka as the orderering backend
[configtxlator](docs/configtxlator.md) | Use configtxlator to convert the configurations
[WIP] [Some verification tests](docs/verification_test.md) | 


## Acknowledgement
* [Hyperledger Fabric](https://github.com/hyperledger/fabric/) project.
* [Hyperledger Fabric Getting Started](http://hyperledger-fabric.readthedocs.io/en/latest/getting_started.html).
