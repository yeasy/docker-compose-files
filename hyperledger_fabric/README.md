# Hyperledger Fabric

This project provides several useful Docker-Compose script to help quickly bootup a Hyperledger Fabric network, and do simple testing with deploy, invoke and query transactions.

Currently we support Hyperledger Fabric v0.6.x and v1.x.

If you're not familiar with Docker and Blockchain, can have a look at these books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)


## Getting Started

### Pick up a fabric version

Enter the subdir of specific version, e.g., 

```bash
$ cd 1.0.5 # select a fabric version
```

### Quick Test

The following command will run the entire process (start a fabric network, create channel, test chaincode and stop it.) pass-through.

```bash
$ make setup # Install docker/compose, and pull required images
$ make test  # Test with default fabric solo mode
```

### Test with more modes

```bash
$ HLF_MODE=solo make test # in solo mode
$ HLF_MODE=kafka make test # in kafka mode
$ HLF_MODE=couchdb make test  # solo+couchdb support, web UI is at `http://localhost:5984/_utils`
$ HLF_MODE=event make test  # Enable eventhub listener
```

### Detailed Steps

See [detailed steps](docs/steps.md)

## Supported Fabric Releases

Fabric Release | Description
--- | ---
[Fabric v0.6.0](v0.6.0/) | stable with fabric v0.6.0 code.
[Fabric v1.0.0](v1.0.0/) | stable with fabric v1.0.0 code.
[Fabric v1.0.2](v1.0.2/) | deprecated, test fabric v1.0.2 code.
[Fabric v1.0.4](v1.0.4/) | test fabric v1.0.4 code.
[Fabric v1.0.5](v1.0.5/) | latest stable fabric code with v1.0.5.
[Fabric Latest](latest/) | experimental with latest fabric code, unstable.

## Acknowledgement
* [Hyperledger Fabric](https://github.com/hyperledger/fabric/) project.
* [Hyperledger Fabric Getting Started](http://hyperledger-fabric.readthedocs.io/en/latest/getting_started.html).
