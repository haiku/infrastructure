# Deploying Haiku Compute Nodes

This guide will walk you through deploying Haiku compute nodes. In this document we will be using
DigitalOcean, however anything https://rexray.io supports should work in theory.

## Common steps

**Install Base Requirements**
```
yum install git vim
curl -fsSL https://get.docker.com/ | sh
curl -sSL https://rexray.io/install | sh
systemctl enable docker
systemctl start docker
```

## Setup Docker Swarm

**On the first node of the region**

> XX.XX.XX.XX is the private IP of the instance

```
docker swarm init --advertise-addr XX.XX.XX.XX
```

**On each additional node of the region**

> XXXXX YYYYY are provided by the init above

```
docker swarm join --token XXXXX YYYYYY
```

## Setup Volume Driver

> Ensure you change the region from ams3 to the target region.

**Install rexray for DigitalOcean on each node**
```
docker plugin install rexray/dobs DOBS_CONVERTUNDERSCORES=true DOBS_REGION=ams3 DOBS_TOKEN=XXXX
```
