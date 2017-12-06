# Hyperledger Fabric

This project provides several useful Docker-Compose script to help quickly bootup a Hyperledger Fabric network, and do simple testing with deploy, invoke and query transactions.

Currently we support Hyperledger Fabric v0.6 and v1.0.

If you're not familiar with Docker and Blockchain, can have a look at these books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)


## Getting Started

### Pick up a fabric version to test

Take fabric v1.0.4 for example

```bash
$ cd 1.0.4 #
$ HLF_MODE=solo make
$ HLF_MODE=kafka make
$ HLF_MODE=couchdb make
$ HLF_MODE=dev make
```

## Supported Releases

* [Fabric v0.6.0](0.6.0/): stable with fabric v0.6.0 code.
* [Fabric v1.0.0](1.0.0/): stable with fabric v1.0.0 code.
* [Fabric v1.0.2](1.0.2/): deprecated, test fabric v1.0.2 code.
* [Fabric v1.0.3](1.0.3/): deprecated, test fabric v1.0.3 code.
* [Fabric v1.0.4](1.0.4/): test fabric v.1.0.4 code.
* [Fabric Latest](latest/): experimental with latest fabric code, unstable.

