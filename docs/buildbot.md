# Buildbot Worker Administration

Buildbot Workers are nodes which perform the heavy lifting. These nodes are generally run by trusted individuals running all over the world.

## Cleanup old buildbot 0.8.x slaves

* ```systemctl stop buildbot-slave```
* ```systemctl disable buildbot-slave```
* ```rm /etc/systemd/system/buildbot-slave.service```
* Uninstall any packaged buildbot-slave packages. (```rpm -e buildbot-slave```)
* rm -rf /var/lib/buildbot/slaves

## Installing latest buildbot worker

* ```pip install buildbot-worker``` as root
* ```mkdir -p /var/lib/buildbot/workers```
* ```chown bbot:bbot /var/lib/buildbot/workers```
* ```su - bbot```
* ```buildbot-worker create-worker --umask=022 /var/lib/buildbot/workers/haiku/ build.haiku-os.org:9989 WORKERNAME WORKERPASSWORD```
* Update systemd service.
  * create /etc/systemd/system/buildbot-worker.service
  ```
  [Unit]
  Description=BuildBot worker service
  After=network.target

  [Service]
  User=bbot
  Group=bbot
  Type=forking
  WorkingDirectory=/home/bbot
  UMask=0022
  ExecStart=/usr/bin/buildbot-worker start /var/lib/buildbot/workers/haiku

  [Install]
  WantedBy=multi-user.target
  ```
* systemctl daemon-reload
* systemctl enable buildbot-worker
* systemctl start buildbot-worker
* systemctl status buildbot-worker
