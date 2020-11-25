#!/bin/bash

# remove container so can recreate it
docker stop frontend
docker rm -v frontend

TOP=$(pwd)

docker run --name frontend --net=host --restart=always -d \
    -v /srv/www/ports-mirror:/ports-mirror:ro \
    -v /srv/www/haikufiles/files:/haiku-files:ro \
    -v /home/haikufiles:/home/haikufiles:ro \
    -v $TOP/nginx.conf:/etc/nginx/nginx.conf:ro \
    -e MONITOR_PATHS="/etc/nginx/nginx.conf /haiku-files/nightly-images/currentImages.map.nginx" \
    nginx-auto:latest
