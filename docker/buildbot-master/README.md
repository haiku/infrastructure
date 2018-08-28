# Haiku Buildbot

# Testing Environment Setup

* Install Docker
* Setup persistant data directory

```
docker volume create infrastructure_gerrit_data
sudo mkdir /var/lib/docker/volumes/infrastructure_gerrit_data/_data/git
sudo git clone --bare https://review.haiku-os.org/haiku /var/lib/docker/volumes/infrastructure_gerrit_data/_data/git/haiku.git
sudo git clone --bare https://review.haiku-os.org/buildtools /var/lib/docker/volumes/infrastructure_gerrit_data/_data/git/buildtools.git
```

# Testing

* Build container: ```make```
* Launch container: ```make test```
