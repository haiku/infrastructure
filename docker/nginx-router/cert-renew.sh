#!/bin/bash

# Bring down the docker nginx http/https router (which consumes 443)
docker-compose -f /root/infrastructure/docker/nginx-router/docker-compose.yml down
sleep 5
# Open 443 for certbot
iptables -A INPUT -p tcp -m state --dport 443 --state NEW -m tcp -j ACCEPT
certbot certonly --standalone -n -d review.haiku-os.org
sleep 5
# Close 443 to return to docker
iptables -D INPUT -p tcp -m state --dport 443 --state NEW -m tcp -j ACCEPT

# Bring docker nginx http/https router back online
docker-compose -f /root/infrastructure/docker/nginx-router/docker-compose.yml up -d
