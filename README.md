Docker Compose Files
===
Some typical docker compose templates.

# Install Docker Compose
```sh
$ sudo pip install docker-compose
```

# Docker-compose Usage
See [https://docs.docker.com/compose/](https://docs.docker.com/compose/).


# templates

## mongo_cluster
Start 3 mongo instance to make a replica set.

## mongo_webui
Start 1 mongo instance and a mongo-express web tool to watch it.

The mongo instance will store data into local /opt/data/mongo_home.

The web UI will listen on local 8081 port.
