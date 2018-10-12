docker-compose down
docker rm -f $(docker ps -aq --filter name=dev-peer)
docker rm -f $(docker ps -aq --filter name=net_)
log "Docker containers have been stopped"