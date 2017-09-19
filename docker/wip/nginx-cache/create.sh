#!/bin/bash

# remove container so can recreate it
docker stop reverse-proxy
docker rm -v reverse-proxy

TOP=$(pwd)

# generate our nginx.conf
./generate_conf.sh api buildbot buildbot-test download ports-mirror userguide

docker run --name reverse-proxy --net=host --restart=always -d \
    -v /etc/letsencrypt:/letsencrypt:ro \
    -v $TOP/nginx.conf:/etc/nginx/nginx.conf:ro \
    nginx:alpine
