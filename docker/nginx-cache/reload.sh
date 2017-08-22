#!/bin/bash

# generate our nginx.conf
./generate_conf.sh api buildbot buildbot-test download ports-mirror userguide

docker kill -s HUP reverse-proxy
