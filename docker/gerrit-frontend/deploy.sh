#!/bin/bash
docker stop gerrit || true
docker rm gerrit || true
docker pull gerritforge/gerrit-centos7
docker run -d --name gerrit --restart unless-stopped --cpus=1.0 \
    -p 8080:8080 -p 29418:29418 \
    -v gerrit-db:/var/gerrit/db -v gerrit-etc:/var/gerrit/etc -v gerrit-git:/var/gerrit/git \
    -v gerrit-index:/var/gerrit/index -v gerrit-cache:/var/gerrit/cache \
    gerritforge/gerrit-centos7
