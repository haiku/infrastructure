#!/bin/bash
if [[ $# -ne 1 ]]; then
	echo "usage: $0 <users.csv>"
	exit 1
fi

if [[ "$ADMIN_USER" == "" ]] || [[ "$ADMIN_PASS" == "" ]]; then
	echo "please define (ldap) ADMIN_USER and ADMIN_PASS before using"
	exit 1
fi

BASE_DN="dc=haiku-os,dc=org"
LDAPADD="ldapadd -x -D cn=$ADMIN_USER,$BASE_DN -H ldap://ldap:1389 -w $ADMIN_PASS"

while read p; do
	ACTIVE=$(echo $p | awk -F "\"*,\"*" '{print $15}')
	USERNAME=$(echo $p | awk -F "\"*,\"*" '{print $3}' | tr '[:upper:]' '[:lower:]')
	if [[ "$ACTIVE" == "false" ]]; then
		echo "Failed: Ignoring $USERNAME due to inactive status"
		continue
	fi
	TRUST=$(echo $p | awk -F "\"*,\"*" '{print $10}')
	if [[ "$TRUST" == "0" ]]; then
		echo "Failed: Ignoring $USERNAME due to trust 0!"
		continue
	fi
	NAME=$(echo $p | awk -F "\"*,\"*" '{print $2}')
	CN=$(echo $NAME | cut -d' ' -f1)
	SN=$(echo $NAME | sed "s/^$CN//")
	if [[ "$SN" == "" ]]; then
		SN="Unknown"
	fi
	EMAIL=$(echo $p | awk -F "\"*,\"*" '{print $4}')
	echo "dn: uid=$USERNAME,ou=users,$BASE_DN" > /tmp/newuser
	echo "objectClass: top" >> /tmp/newuser
	echo "objectClass: iNetOrgPerson" >> /tmp/newuser
	echo "sn: $SN" >> /tmp/newuser
	echo "cn: $CN" >> /tmp/newuser
	echo "displayName: $NAME" >> /tmp/newuser
	echo "mail: $EMAIL" >> /tmp/newuser
	echo "uid: $USERNAME" >> /tmp/newuser
	$LDAPADD -f /tmp/newuser
	if [[ $? -eq 0 ]]; then
		echo "Success: Added $USERNAME to Haiku LDAP"
	else
		echo "Failed: Unable add $USERNAME to Haiku LDAP"
	fi
done <$1
