#!/usr/bin/env bash

# This script will remove all containers and hyperledger related images

# Detecting whether can import the header file to render colorful cli output
# Need add choice option
if [ -f ./header.sh ]; then
 source ./header.sh
elif [ -f scripts/header.sh ]; then
 source scripts/header.sh
else
 alias echo_r="echo"
 alias echo_g="echo"
 alias echo_b="echo"
fi

while true
        do
            echo_b  " ================== Clean up env  ================\n"
            echo_b  "1        Clean all containers"
            echo_b  "2        Clean all chaincode-images"
            echo_r  "3        [warning]Clean all hyperledger-images"
            echo_b  "q        quit"
            echo_b  "  ==================================\n"
            read -p "Choice the number and enter:" select
            echo_b  "====================================\n"
            case $select in
            q|Q)
                    break
                    ;;
            1)
                    echo_b "Clean up all containers..."
                    docker rm -f `docker ps -qa`
                    ;;
            2)
                    echo_b "Clean up all chaincode-images..."
                    docker rmi -f $(docker images |grep 'dev-peer*'|awk '{print $3}')
                    ;;
            3)
                    echo_b "Clean up all hyperledger related images..."
                    docker rmi $(docker images |grep 'hyperledger')
                    ;;
            esac
        done
echo_g "Env cleanup done!"