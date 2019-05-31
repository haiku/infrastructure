# Server Rebuild
... or 'we broke everything, and need to fix everything ASAP.'

## Introduction

Take a deep breath, you're now in charge of fixing the mess you
(or someone else made).  Everything is down, IRC users in #haiku
and #haiku-dev are panicking. Lets go!


## Backup, Backup, Backup

*everything* unique to our infrastructure should be contained within the following path:
	/var/lib/docker/volumes

This path is an iSCSI mount from online.net

If you can get a 100% perfect copy of /var/lib/docker/volumes you're
in the clear.  /var/lib/docker/volumes is *big* however since it
contains all of our build artifacts.

/var/lib/docker/volumes is continously snapshot and backed up to the local machine
at /var/backup

If you're in a bad way, (but have access to the filesystem), be sure
to run a final sync of ```/var/lib/docker/volumes``` to Hetzner to have the
"most live" backup possible.

## Reinstall!

Setup a new Linux machine. (I like CentOS, Fedora Server, etc... but you're the man
now dog! It's your choice)

I'd recommend a small OS disk (in a RAID of some sort), and a seperate RAID or 
remote NAS resource for the pesistant docker volumes at /var/lib/docker/volumes.

(I'd highly recommend a real hardware RAID... and *NEVER* use a software RAID
for the OS boot disk and our persistant data. We have done this before, and when
things go bad they go *BAD* and our persistant data gets put at risk)

Reboot into your new server.

Configure network (/etc/sysconfig/network-scripts/ifcfg-en*):
```
NAME="enwhatever"
DEVICE="enwhatever"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=yes
BOOTPROTO=static
IPADDR=whatever
NETMASK=whatever
GATEWAY=whatever
IPADDR1=whatever1
NETMASK1=whatever1
TYPE=Ethernet
DNS1=8.8.8.8
```

Apply any available OS updates, reboot again.

## Configure

Install the packages you'll need. (These examples are for CentOS/Fedora)

```dnf install git docker docker-compose iptables-service vim wget```

Configure your backend storage for docker. I did btrfs since i've had good
experience using it for docker persistant volumes in prod... but RHEL seems to
be dropping it :-(.  Just make sure whatever you choose is suitable for
docker production.

Setup your services, switch to iptables vs firewalld...
```
setenforce 0
systemctl disable firewall
systemctl mask firewall
systemctl enable iptables
systemctl start iptables
systemctl enable docker
systemctl start docker
```

Validate docker is happy via ```docker info```

As root, get infrastructure directory. Put into root's home.
```
git clone https://github.com/haiku/infrastructure.git
```

## Install vault client

https://www.vaultproject.io/downloads.html
extract vault binary to /usr/local/bin/

## Configure SSH

Ensure your ssh public key is in ~/.ssh/authorized_keys (and ensure it works).

Set PasswordAuthentication to no
Configure sshd to only listen on 94.130.128.252 via /etc/ssh/sshd_config.

```
systemctl restart ssh
```

## Restore persistant data

Let docker-compose create all the docker volumes for you...

Start "everything"
```
cd ~/infrastructure
docker-compose up -d
```

Shutdown "everything"
```
docker-compose down
```

Restore "hot" persistant data (replace XXX with login from keepass info)
```
rsync --progress -e 'ssh -p23' --recursive uXXXXXX@uXXXXX.your-backup.de:./maui/ /var/lib/docker/volumes/
```

Restore the build artifacts however you can to ```/var/lib/docker/volumes/infrastructure_s3_data```


Start vault
```
cd ~/infrastructure
docker-compose up -d vault
export VAULT_ADDR=http://127.0.0.1:8200
```

Check vault connection
```
vault status
```

Unseal vault
To unseal the vault, you'll need 3 of the 5 unseal keys.
```
vault operator unseal
```

Check vault is unsealed
```
vault status
```

Start "everything else"
```
cd ~/infrastructure
docker-compose up -d
```

## Reconfigure user accounts

Make sure you re-add the local user accounts for the sysadmin team members.

## Congratulations!

Now run over ```docker-compose ps```, and fix any minor remaining issues.

