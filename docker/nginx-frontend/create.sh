#!/bin/bash

# let's us use inotify to automatically update configuration
# TODO: use environment variables to specify files/directories to watch
docker build . --tag nginx-auto:latest

# remove container so can recreate it
docker stop frontend
docker rm -v frontend

TOP=$(pwd)

docker run --name frontend --net=host --restart=always -d \
    -v /etc/letsencrypt:/letsencrypt:ro \
    -v /srv/www/ports-mirror:/ports-mirror:ro \
    -v /srv/www/haikufiles/files:/haiku-files:ro \
    -v /home/haikufiles:/home/haikufiles:ro \
    -v $TOP/nginx.conf:/etc/nginx/nginx.conf:ro \
    nginx-auto:latest
