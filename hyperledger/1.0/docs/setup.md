## Manually Setup


### Install Docker/Docker-Compose

```sh
$ bash scripts/setup_Docker.sh  # Install Docker, Docker-Compose 
```

### Download Images

Pull necessary images of peer, orderer, ca, and base image. You may optionally run the clean_env.sh script to remove all existing container and images.

```sh
$ bash scripts/cleanup_env.sh
$ bash scripts/download_images.sh
```

There are also some community [images](https://hub.docker.com/r/hyperledger/) at Dockerhub, use at your own choice.

Now you can try [chaincode test](chaincode_test.md) operations with the bootup fabric network.