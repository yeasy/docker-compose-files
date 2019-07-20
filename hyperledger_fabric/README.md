# Hyperledger Fabric Playground

This project provides several useful Docker-Compose script to help quickly bootup a Hyperledger Fabric network, and do simple testing with deploy, invoke and query transactions.

Currently we support Hyperledger Fabric all releases from v0.6 to latest v1.x.

If you're not familiar with Docker and Blockchain, can have a look at these books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)

## Supported Fabric Releases

Fabric Release | Description
--- | ---
[Fabric Latest](latest/) | latest fabric code, unstable.
[Fabric v1.4.2](v1.4.2/) | stable fabric 1.4.2 release.
[Fabric v1.4.0](v1.4.0/) | stable fabric 1.4.0 release.
[Fabric v1.3.0](v1.3.0/) | stable fabric 1.3.0 release.
[Fabric v1.2.0](v1.2.0/) | stable fabric 1.2.0 release.
[Fabric v1.1.0](v1.1.0/) | stable fabric 1.1.0 release.
[Fabric v1.0.6](v1.0.6/) | fabric v1.0.6 release.
[Fabric v1.0.0](v1.0.0/) | fabric v1.0.0 release.
[Fabric v0.6.0](v0.6.0/) | fabric v0.6.0 release (too old, not recommend to use).


## Getting Started

### TLDR

```bash
$ export RELEASE=v1.4.2
```

```bash
$ cd ${RELEASE}; make setup test
```

More details are releaved below.

### Pick up a fabric version

Enter the subdir of specific version and setup, e.g.,

```bash
$ cd ${RELEASE} # select a fabric version
$ make setup download # Install docker/compose, and pull required images
```

### Quick Test

The following command will run the entire process (start a fabric network, create channel, test chaincode and stop it.) pass-through.

```bash
$ make test  # Test with default fabric solo mode
```

[Prometheus](https://prometheus.io) dashboard listens at [http://localhost:9090](http://localhost:9090) to track the network statistics.

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

## Specify Version Numbers

* `.env`: docker images tags, used by those docker-compose files;
* `scripts/variable.sh`: docker images tags and project versions, used by scripts;

## Acknowledgement

* [Hyperledger Fabric](https://github.com/hyperledger/fabric/) project.
