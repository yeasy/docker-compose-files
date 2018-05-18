# Hyperledger Fabric Playground

This project provides several useful Docker-Compose script to help quickly bootup a Hyperledger Fabric network, and do simple testing with deploy, invoke and query transactions.

Currently we support Hyperledger Fabric v0.6.x and v1.x.

If you're not familiar with Docker and Blockchain, can have a look at these books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)

## Supported Fabric Releases

Fabric Release | Description
--- | ---
[Fabric v0.6.0](v0.6.0/) | fabric v0.6.0 release (too old, not recommend to use).
[Fabric v1.0.0](v1.0.0/) | fabric v1.0.0 release.
[Fabric v1.0.2](v1.0.2/) | fabric v1.0.2 release.
[Fabric v1.0.5](v1.0.5/) | fabric v1.0.5 release.
[Fabric v1.0.6](v1.0.6/) | fabric v1.0.6 release.
[Fabric v1.1.0](v1.1.0/) | latest stable fabric 1.1.0 release.
[Fabric Latest](latest/) | experimental with latest fabric code, unstable.


## Getting Started

### Pick up a fabric version

Enter the subdir of specific version, e.g.,

```bash
$ cd 1.0.6 # select a fabric version
```

### Quick Test

The following command will run the entire process (start a fabric network, create channel, test chaincode and stop it.) pass-through.

```bash
$ make setup download # Install docker/compose, and pull required images
$ make test  # Test with default fabric solo mode
```

### Test with more modes

```bash
$ HLF_MODE=solo make test # Bootup a fabric network with solo mode
$ HLF_MODE=couchdb make test # Enable couchdb support, web UI is at `http://localhost:5984/_utils`
$ HLF_MODE=event make test  # Enable eventhub listener
$ HLF_MODE=kafka make test # Bootup a fabric network with kafka mode
$ HLF_MODE=be make test  # Start a blockchain-explorer to view network info
```

## Detailed Steps

See [detailed steps](docs/steps.md)

## TODO

* Support boot up a fabric network with hyperledger composer

## Acknowledgement

* [Hyperledger Fabric](https://github.com/hyperledger/fabric/) project.
