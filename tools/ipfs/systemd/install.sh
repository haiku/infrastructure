#!/bin/bash
cp *.service *.timer /etc/systemd/system/
systemctl daemon-reload
systemctl enable ipfs
systemctl enable mfs-haiku
systemctl enable mfs-haikuports
systemctl enable mfs-publish
