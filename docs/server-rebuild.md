# Server Rebuild
... or 'we broke everything, and need to fix everything ASAP.'

## Introduction

Take a deep breath, you're now in charge of fixing the mess you
(or someone else made).  Everything is down, IRC users in #haiku
and #haiku-dev are panicking. Lets go!


## Backup, Backup, Backup

*everything* unique to maui should be contained within the following path:
	/var/lib/docker/volumes

If you can get a 100% perfect copy of /var/lib/docker/volumes you're
in the clear.  /var/lib/docker/volumes is *big* however since it
contains all of our build artifacts.

/var/lib/docker/volumes is rsync'ed to Hetzner's backup space for maui
(except for the build artifacts. We skip infrastructure_s3_data since
Hetzner gives us a 100GB limit)

If you're in a bad way, (but have access to the filesystem), be sure
to run a final sync ov /var/lib/docker/volumes to Hetzner to have the
"most live" backup possible.

## Reinstall!

Do *NOT* use the "Linux" install option at Hetzner. It creates a horrid
2TiB root mdadm/ext4 partition which is extremely difficult to recover.
Use the VNC option and do the install there.  The VNC options are limited,
but they do have Fedora which I like (you're the new boss, do what you like).

Configure ~200GiB for root, leave the rest of the space empty. Make sure
some RAID is in place. (I used btrfs RAID1 for the "current" maui since
I now consider mdadm the devil on root filesystems)

* Set hostname to maui.haiku-os.org
* Install, create yourself a non-root user.
* Configure the static ip of 94.130.128.252.

Reboot into your new maui.

Configure network (/etc/sysconfig/network-scripts/ifcfg-enp0s31f6):
```
NAME="enp0s31f6"
DEVICE="enp0s31f6"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=yes
BOOTPROTO=static
IPADDR=94.130.128.252
NETMASK=255.255.255.192
GATEWAY=94.130.128.193
IPADDR1=94.130.158.38
NETMASK1=255.255.255.248
TYPE=Ethernet
DNS1="213.133.99.99"
```

Apply any available OS updates, reboot again.

## Configure

Install the packages you'll need. (These examples are for CentOS/Fedora)

```dnf install git docker docker-compose iptables-service vim```

Configure your backend storage for docker. I did btrfs since it (once
again) offers lightweight raid1 without mdadm. It should be mounted
at /var/lib/docker.

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


Start "everything"
```
cd ~/infrastructure
docker-compose up -d
```

## Congratulations!

Now run over ```docker-compose ps```, and fix any minor remaining issues.

