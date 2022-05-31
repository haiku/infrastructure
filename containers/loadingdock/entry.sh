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

# Collect ssh public keys from users in gerrit
for id in ${GERRIT_UIDS}; do
	git fetch origin refs/users/${id:(-2)}/${id}:${id}
	git checkout ${id}
	if [ -f authorized_keys ]; then
		cat authorized_keys >> /etc/authorized_keys/submit
	else
		echo "No authorized_keys for UID $id!"
	fi
done
chown -R submit:users /etc/authorized_keys/submit
chmod 600 /etc/authorized_keys/submit

# setup build-packages directories
mkdir -p /sftp/build-packages
chmod 750 /sftp/build-packages

chown -R submit:users /sftp/build-packages/${arch}
for arch in arm arm64 m68k ppc sparc riscv64 x86 x86_64; do
	mkdir -p /sftp/build-packages/${arch}
	chown -R submit:users /sftp/build-packages/${arch}
	chmod 770 /sftp/build-packages/${arch}
done

echo "Upload new packages to the relevant directory!" > /sftp/README
echo "" >> /sftp/README
echo "  * build-packages - New build-packages (locally build, maybe unbootstraped)" >> /sftp/README
chown root:root /sftp /sftp/README
chmod 611 /sftp/README
chmod 755 /sftp

exec "$@"
