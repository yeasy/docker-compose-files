#! /bin/bash


if [ xroot != x$(whoami) ]
then
   echo "You must run as root (Hint: sudo su)"
   exit
fi

apt-get update

apt-get install curl -y

wget -qO- https://get.docker.com/ | sh 
sudo service docker stop
nohup sudo docker daemon --api-cors-header="*" -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock&

curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

ARCH=x86_64
BASE_VERSION=1.0.0-preview
PROJECT_VERSION=1.0.0-preview
docker pull yeasy/hyperledger-fabric-base:0.8.2 \
  && docker pull yeasy/hyperledger-fabric-peer:0.8.2 \
  && docker pull yeasy/hyperledger-fabric-orderer:0.8.2 \
  && docker pull yeasy/hyperledger-fabric-ca:0.8.2 \
  && docker pull yeasy/blockchain-explorer:latest \
  && docker tag yeasy/hyperledger-fabric-peer:0.8.2 hyperledger/fabric-peer \
  && docker tag yeasy/hyperledger-fabric-orderer:0.8.2 hyperledger/fabric-orderer \
  && docker tag yeasy/hyperledger-fabric-ca:0.8.2 hyperledger/fabric-ca \
  && docker tag yeasy/hyperledger-fabric-base:0.8.2 hyperledger/fabric-baseimage \
  && docker tag yeasy/hyperledger-fabric-base:0.8.2 hyperledger/fabric-ccenv:$ARCH-$BASE_VERSION \
  && docker tag yeasy/hyperledger-fabric-base:0.8.2 hyperledger/fabric-bareos:$ARCH-$BASE_VERSION

docker-compose up
