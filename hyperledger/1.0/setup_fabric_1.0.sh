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

docker pull yeasy/hyperledger-fabric-base:latest \
  && docker pull yeasy/hyperledger-fabric-peer:latest \
  && docker pull yeasy/hyperledger-fabric-orderer:latest \
  && docker pull yeasy/hyperledger-fabric-ca:latest \
  && docker pull yeasy/blockchain-explorer:latest \
  && docker tag yeasy/hyperledger-fabric-peer hyperledger/fabric-peer \
  && docker tag yeasy/hyperledger-fabric-orderer hyperledger/fabric-orderer \
  && docker tag yeasy/hyperledger-fabric-ca hyperledger/fabric-ca \
  && docker tag yeasy/hyperledger-fabric-base hyperledger/fabric-baseimage \
  && docker tag yeasy/hyperledger-fabric-base hyperledger/fabric-ccenv:x86_64-1.0.0-snapshot-preview

docker-compose up
