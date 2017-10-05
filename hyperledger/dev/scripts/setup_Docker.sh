#!/usr/bin/env bash

# Install docker on Ubuntu/Debian system

# Detecting whether can import the header file to render colorful cli output
if [ -f ./header.sh ]; then
 source ./header.sh
elif [ -f scripts/header.sh ]; then
 source scripts/header.sh
else
 alias echo_r="echo"
 alias echo_g="echo"
 alias echo_b="echo"
fi

if [ xroot != x$(whoami) ]
then
   echo_r "You must run as root (Hint: sudo su)"
   exit
fi

apt-get update && apt-get install curl -y

echo_b "Install Docker..."

wget -qO- https://get.docker.com/ | sh 
sudo service docker stop
nohup sudo docker daemon --api-cors-header="*" -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock&

echo_g "Docker Installation Done"

echo_b "Install Docker-Compose..."

curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version


echo_g "Docker-Compose Installation Done"

