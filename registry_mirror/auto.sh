#!/bin/sh
echo "Start the registry service using docker-compose"

docker-compose -p registry -f docker-compose.yml up -d
