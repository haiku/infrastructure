# Deploying Haiku Swarm Compute Nodes

This guide will walk you through deploying Haiku compute nodes. In this document we will be using
DigitalOcean, however anything https://rexray.io supports should work in theory.

> DigitalOcean has a *fixed* limit of 7 volume attachments per node! Keep nodes small unless you
> *really* need the cpu / memory!

## Common steps

**Install Base Requirements**
```
yum install git vim iptables-services
sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin yes/PermitRootLogin without-password/' /etc/ssh/sshd_config
sed -i 's/^-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT/-A INPUT -p tcp -m state --state NEW -m tcp --dport 2222 -j ACCEPT/' /etc/sysconfig/iptables
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 2222 -j ACCEPT
semanage port -a -t ssh_port_t -p tcp 2222
systemctl restart sshd
(reconnect on port 2222)
cd /root && git clone https://github.com/haiku/infrastructure.git
curl -fsSL https://get.docker.com/ | sh
curl -sSL https://rexray.io/install | sh
systemctl enable iptables
systemctl restart iptables
systemctl enable docker
systemctl start docker
```

## Setup Docker Swarm

**On the first (master) node of the region**

> XX.XX.XX.XX is the private IP of the instance

```
docker swarm init --advertise-addr XX.XX.XX.XX
```

**On each additional node of the region**

> XXXXX YYYYY are provided by the init above

```
docker swarm join --token XXXXX YYYYYY
```

**If you're attaching additional nodes to an existing cluster**

Generate a new join-token:
```
docker swarm join-token worker
```

Join the new node to the swarm:
```
docker swarm join --token XXXXX YYYYYY
```

## Setup Volume Driver

> Ensure you change the region from ams3 to the target region.

**Install rexray for DigitalOcean on each node**
```
docker plugin install rexray/dobs DOBS_CONVERTUNDERSCORES=true DOBS_REGION=ams3 DOBS_STATUSINITIALDELAY="500ms" DOBS_TOKEN=XXXX
```

## Assign Node Labels

**Shared Storage**

Our environment requires node labels to ensure containers sharing storage reside on the same host.
One node in the environment needs to have each of the following labels:

> Please add additional shared disk labels as required to this list!

  * git
  * cdn
  * build

Labels can be applied to nodes via:
```
docker node update --label-add git=true (node_hostname)
```

**Node Sizes**

Smaller services target smaller nodes, larger services target larger nodes.
We label nodes as follows:

  * **small** 1 vCPU, 2GiB of RAM, 60 GiB SSD
  * **medium** 2 vCPU, 4GiB of RAM, 80 GiB SSD
  * **large** 4 vCPU, 8GiB of RAM, 160 GiB SSD

> As of this writing, we have two medium, one small.

```
docker node update --label-add tier=small (node_hostname)
```
