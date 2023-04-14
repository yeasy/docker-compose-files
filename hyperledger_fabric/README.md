# Hyperledger Fabric Playground

This project provides several useful Docker-Compose script to help quickly bootup a Hyperledger Fabric network, and do simple testing with deploy, invoke and query transactions.

Currently we support Hyperledger Fabric all releases from v0.6.0, 1.x to latest 2.x.

If you're not familiar with Docker and Blockchain, can have a look at these books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)

## Supported Fabric Releases

Fabric Release | Description
--- | ---
[Fabric Latest](latest) | latest fabric code, unstable.
[Fabric v2.5.0](v2.5.0) | fabric 2.5.0 release.
[Fabric v2.4.0](v2.4.0) | fabric 2.4.0 release.
[Fabric v2.3.3](v2.3.3) | fabric 2.3.3 release.
[Fabric v2.3.0](v2.3.0) | fabric 2.3.0 release.
[Fabric v2.2.8](v2.2.8) | fabric 2.2.8 LTS release.
[Fabric v2.2.4](v2.2.4) | fabric 2.2.4 LTS release.
[Fabric v2.2.1](v2.2.1) | fabric 2.2.1 LTS release.
[Fabric v2.2.0](v2.2.0) | fabric 2.2.0 LTS release.
[Fabric v2.1.0](v2.1.0) | fabric 2.1.0 release.
[Fabric v2.0.0](v2.0.0) | fabric 2.0.0 release.
[Fabric v1.4.9](v1.4.9) | fabric 1.4.9 LTS release.
[Fabric v1.4.8](v1.4.8) | fabric 1.4.8 LTS release.
[Fabric v1.4.7](v1.4.7) | fabric 1.4.7 LTS release.
[Fabric v1.4.6](v1.4.6) | fabric 1.4.6 LTS release.
[Fabric v1.4.5](v1.4.5) | fabric 1.4.5 LTS release.
[Fabric v1.4.4](v1.4.4) | fabric 1.4.4 LTS release.
[Fabric v1.4.3](v1.4.3) | fabric 1.4.3 release.
[Fabric v1.4.2](v1.4.2) | fabric 1.4.2 release.
[Fabric v1.4.0](v1.4.0) | fabric 1.4.0 release.
[Fabric v1.3.0](v1.3.0) | fabric 1.3.0 release.
[Fabric v1.2.0](v1.2.0) | fabric 1.2.0 release.
[Fabric v1.1.0](v1.1.0) | fabric 1.1.0 release.
[Fabric v1.0.6](v1.0.6) | fabric v1.0.6 release.
[Fabric v1.0.0](v1.0.0) | fabric v1.0.0 release.
[Fabric v0.6.0](v0.6.0) | fabric v0.6.0 release (too old, not recommend to use).

## Getting Started

### TLDR

```bash
$ export RELEASE=v2.5.0
```

```bash
$ cd ${RELEASE}; make setup test
```

More details are as below.

### Pick up a fabric version

Enter the subdir of specific version and setup, e.g.,

```bash
$ cd ${RELEASE} # select a fabric version
$ make setup download # Install docker/compose, and pull required images
```

### Quick Test

The following command will run the entire process (start a fabric network, create channel, test chaincode and stop it.) pass-through.

```bash
$ make test  # Test with default fabric RAFT mode
```

[Prometheus](https://prometheus.io) dashboard listens at [http://localhost:9090](http://localhost:9090) to track the network statistics.

### Test with more modes

In v2.x, only raft is supported.

In v1.4.x, solo and kafka are also supported.

```bash
$ HLF_MODE=raft make test # Bootup a fabric network with solo mode
```

## Detailed Steps

See [detailed steps](docs/steps.md)

## Specify Version Numbers

* `.env`: docker images tags, used by those docker-compose files;
* `scripts/variable.sh`: docker images tags and project versions, used by scripts;

## Acknowledgement

* [Hyperledger Fabric](https://github.com/hyperledger/fabric/) project.
