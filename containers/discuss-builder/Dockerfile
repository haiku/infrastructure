FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    docker.io \
    git \
    iproute2

RUN git clone git://github.com/discourse/discourse_docker /var/discourse/docker
COPY ./containers /var/discourse/docker/containers
