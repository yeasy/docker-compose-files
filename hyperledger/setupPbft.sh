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

docker pull yeasy/hyperledger-fabric:latest \
    && docker tag yeasy/hyperledger-fabric:latest hyperledger/fabric-peer:latest \
    && docker tag yeasy/hyperledger-fabric:latest hyperledger/fabric-baseimage:latest \
    && docker tag yeasy/hyperledger-fabric:latest hyperledger/fabric-membersrvc:latest

cd pbft
docker-compose up

#test: curl HOST:5000/network/peers
