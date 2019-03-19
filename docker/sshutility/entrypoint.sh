#!/bin/sh

echo "Generating host keys..."
ssh-keygen -A

echo "Setting up access keys..."
mkdir -p "/root/.ssh/"
cat /root/.keys/* > /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

# and start the ssh daemon
exec /usr/sbin/sshd -D -e "$@"
