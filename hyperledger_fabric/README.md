# Hyperledger Fabric

This project provides several useful Docker-Compose script to help quickly bootup a Hyperledger Fabric network, and do simple testing with deploy, invoke and query transactions.

Currently we support Hyperledger Fabric v0.6 and v1.0.

If you're not familiar with Docker and Blockchain, can have a look at these books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)


## Getting Started

```bash
$ cd 1.0.4
$ HLF_MODE=solo make
$ HLF_MODE=kafka make
$ HLF_MODE=couchdb make
$ HLF_MODE=dev make
```

## Supported Releases

* [Fabric v0.6.0](0.6.0/): stable.
* [Fabric v1.0.0](1.0.0/): stable.
* [Fabric v1.0.2](1.0.2/): deprecated.
* [Fabric v1.0.3](1.0.3/): deprecated.
* [Fabric v1.0.4](1.0.4/): ongoing.
* [Fabric Latest](latest/): experimental.

