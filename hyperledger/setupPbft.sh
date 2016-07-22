#! /bin/bash


if [ xroot != x$(whoami) ]
then
   echo "You must run as root (Hint: sudo su)"
   exit
fi


apt-get install curl -y

wget -qO- https://get.docker.com/ | sh 
sudo service docker stop
nohup sudo docker daemon --api-cors-header="*" -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock&

curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

docker pull yeasy/hyperledger:latest && docker tag yeasy/hyperledger:latest hyperledger/fabric-baseimage:latest
docker pull yeasy/hyperledger-peer:latest
docker pull yeasy/hyperledger-membersrvc:latest

cd pbft
docker-compose up
