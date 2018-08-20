#!/usr/bin/env bash

# Install docker on Ubuntu/Debian system

install_docker() {
	echo "Install Docker..."
	wget -qO- https://get.docker.com/ | sh
	sudo service docker stop
	#nohup sudo docker daemon --api-cors-header="*" -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock&
	echo "Docker Installation Done"
}

install_docker_compose() {
	echo "Install Docker-Compose..."
	command -v "curl" >/dev/null 2>&1 || sudo apt-get update && apt-get install curl -y
	curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	docker-compose --version
	echo "Docker-Compose Installation Done"
}

command -v "docker" >/dev/null 2>&1 && echo "Docker already installed" || install_docker

command -v "docker-compose" >/dev/null 2>&1 && echo "Docker-Compose already installed" || install_docker_compose
command -v "jq" >/dev/null 2>&1 && echo "jq already installed" || sudo apt-get install jq