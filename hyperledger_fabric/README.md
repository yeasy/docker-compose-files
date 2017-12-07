# Hyperledger Fabric

This project provides several useful Docker-Compose script to help quickly bootup a Hyperledger Fabric network, and do simple testing with deploy, invoke and query transactions.

Currently we support Hyperledger Fabric v0.6.x and v1.x.

If you're not familiar with Docker and Blockchain, can have a look at these books (in CN):

* [Docker Practice](https://github.com/yeasy/docker_practice)
* [Blockchain Guide](https://github.com/yeasy/blockchain_guide)


## Getting Started

### Pick up a fabric version to test

Take fabric latest stable code for example

```bash
$ cd 1.0.5 #
$ HLF_MODE=solo make
$ HLF_MODE=kafka make
$ HLF_MODE=couchdb make
$ HLF_MODE=dev make
```

## Supported Releases

* [Fabric v0.6.0](v0.6.0/): stable with fabric v0.6.0 code.
* [Fabric v1.0.0](v1.0.0/): stable with fabric v1.0.0 code.
* [Fabric v1.0.2](v1.0.2/): deprecated, test fabric v1.0.2 code.
* [Fabric v1.0.3](v1.0.3/): deprecated, test fabric v1.0.3 code.
* [Fabric v1.0.4](v1.0.4/): test fabric v1.0.4 code.
* [Fabric v1.0.5](v1.0.5/): latest stable fabric code with v1.0.5.
* [Fabric Latest](latest/): experimental with latest fabric code, unstable.

