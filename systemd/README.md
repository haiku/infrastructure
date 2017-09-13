# systemd for the impaitent (or lazy)

Systemd is awesome, catch the d!

## Install service

 * cp myapp.service /etc/systemd/system/
 * systemctl daemon-reload

## Enable service at boot

 * systemctl enable myapp

## Disable service at boot

 * systemctl disable myapp

## Manage service state

 * systemctl start myapp
 * systemctl stop myapp
 * systemctl restart myapp 

## View service logs

 * journalctl -u myapp

## systemd-docker

systemd-docker is a small tool to improve reliability of
spawning docker containers through systemd.

https://github.com/ibuildthecloud/systemd-docker
https://groups.google.com/forum/#!topic/coreos-dev/wf7G6rA7Bf4/discussion
