#!/bin/bash
##
# if [ $1 -gt 0 ]; then
if  ! [[ -z "$1" ]]; then
# echo "starting $1"
docker build --build-arg PORT=$1 -t cow .
docker run -d -p 4001:$1 --name house_cow cow 
# echo "Cowsey is set on port $1"
else
docker build --build-arg PORT=8081 -t cow .
docker run -d -p 4001:8081 --name house_cow cow 
# echo "Cowsey is set on port 8080"
fi

# docker run --rm -it -p 4001:3001 --name house_cow cow 
# docker run --rm -it --name house_cow cow 
