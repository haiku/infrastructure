#!/bin/bash

GERRIT_SERVER="https://review.haiku-os.org"

if [ -z "${GERRIT_EMAILS}" ]; then
	echo "This tool needs at least one Gerrit uid in GERRIT_EMAILS to allow access to!"
	exit 1
fi

if [ -z "${GERRIT_SA}" ]; then
	echo "This tool need provided a Gerrit service account as GERRIT_SA!"
	exit 1
fi

lookup_gerrit_id() {
        curl -s --header "Content-Type: application/json" \
		--user ${GERRIT_SA} \
                ${GERRIT_SERVER}/a/accounts/?q=name:$1 | egrep -v "^)]}'$" | jq ".[]._account_id"
}

get_ssh_keys() {
	curl -s --header "Content-Type: application/json" \
		--user ${GERRIT_SA} \
		${GERRIT_SERVER}/a/accounts/$1/sshkeys | egrep -v "^)]}'$" | jq -r '.[].ssh_public_key'
}

# TODO: Once we move to kubernetes, keep these in secrets. For now they'll change on every
#       startup
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	ssh-keygen -A
	#ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
	#ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
	#ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
	chmod 700 /etc/ssh/ssh_host*
fi

# Collect ssh public keys from users in gerrit
for email in ${GERRIT_EMAILS}; do
	GERRIT_UID=$(lookup_gerrit_id ${email})
	get_ssh_keys $GERRIT_UID >> /etc/authorized_keys/submit
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
