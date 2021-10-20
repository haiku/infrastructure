#!/bin/bash

if [ -z "${GERRIT_UIDS}" ]; then
	echo "This tool needs at least one Gerrit uid in GERRIT_UIDS to allow access to!"
	exit 1
fi

# TODO: Once we move to kubernetes, keep these in secrets. For now they'll change on every
#       startup
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	ssh-keygen -A
	#ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
	#ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
	#ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
	chmod 700 /etc/ssh/ssh_host*
fi

cd ~
git clone /gerrit/git/All-Users.git
cd All-Users

mkdir -p ~submit/.ssh

# Collect ssh public keys from users in gerrit
for i in ${GERRIT_UIDS}; do
	git fetch origin refs/users/${i:(-2)}/${i}:${i}
	git checkout ${i}
	if [ -f authorized_keys ]; then
		cat authorized_keys >> /etc/authorized_keys/submit
	else
		echo "No authorized_keys for UID $i!"
	fi
done

chown -R submit:users /etc/authorized_keys/submit
chmod 600 /etc/authorized_keys/submit

chown -R submit:users /sftp/*
chown root:root /sftp

exec "$@"
