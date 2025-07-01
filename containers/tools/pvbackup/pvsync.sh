#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "Backup / Restore persistant volume data"
	echo "Usage: $0 [backup|restore] <pv_name>"
	exit 1
fi

if ! [ -x "$(command -v rclone)" ]; then
  echo 'Error: rclone is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v gpg)" ]; then
  echo 'Error: gpg is not installed.' >&2
  exit 1
fi

BASE="/pvs"
ACTION="$1"
VOLUME="$2"

RCLONE_CONFIG_PATH="$HOME/.config/rclone/rclone.conf"
TWOSECRET_PATH="$HOME/.config/twosecret"

if [ ! -f $TWOSECRET_PATH ]; then
	echo "Missing twosecret key at $TWOSECRET_PATH"
	exit 1
fi

if [ ! -f $RCLONE_CONFIG_PATH ]; then
	echo "Missing rclone configuration at $RCLONE_CONFIG_PATH"
	exit 1
fi

if [ ! -z "$REMOTE_PREFIX" ] ;then
	echo "REMOTE_PREFIX is not defined!  This is the bucket name for s3 or other prefix path"
	exit 1
fi

if [ ! -z "$REMOTE_NAME" ] ;then
	echo "REMOTE_NAME is not defined. Defaulting to 'backup' (make sure this matches config file)"
	REMOTE_NAME="backup"
fi

if [[ ! -d "$BASE/$VOLUME" ]]; then
	echo "Error: '$BASE/$VOLUME' isn't present on local container! (pvc not mounted?)"
	exit 1
fi

rclone ls $REMOTE_NAME:$REMOTE_PREFIX/pv-$VOLUME > /dev/null
if [ $? -ne 0 ]; then
	echo "Error: Unable to see within configured storage provider!"
	exit 1
fi

case $ACTION in
	backup)
		SNAPSHOT_NAME=${VOLUME}_$(date +"%Y-%m-%d").tar.xz
		echo "Snapshot ${VOLUME}..."
		cd $BASE/$VOLUME
		# We omit some things we universally don't want to backup
		tar -cvJf /tmp/$SNAPSHOT_NAME \
			--exclude 'tmp/*' --exclude 'backups/*' --exclude 'logs/*' \
			--exclude 'log/*' --exclude 'output/*' *
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted performing snapshot! (tar)"
			exit 1
		fi
		cd /tmp
		echo $TWOSECRET | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo TWOFISH /tmp/$SNAPSHOT_NAME
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted performing encryption! (gpg)"
			rm /tmp/$SNAPSHOT_NAME
			exit 1
		fi
		rm /tmp/$SNAPSHOT_NAME
		rclone copy /tmp/$SNAPSHOT_NAME.gpg $REMOTE_NAME:$REMOTE_PREFIX/pv-$VOLUME/
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted during upload! (rclone)"
			rm /tmp/$SNAPSHOT_NAME.gpg
			exit 1
		fi
		if [[ ! -z "$REMOTE_MAX_AGE" ]]; then
			echo "Cleaning up old backups for $VOLUME over $REMOTE_MAX_AGE old..."
			rclone delete --min-age "$REMOTE_MAX_AGE" $REMOTE_NAME:$REMOTE_PREFIX/pv-$VOLUME/
		fi
		echo "Snapshot of ${VOLUME} completed successfully! ($REMOTE_PREFIX/pv-$VOLUME/$SNAPSHOT_NAME.gpg)"
		;;

	restore)
		# We assume the latest is at the bottom of the rclone ls.
		# It seems to be true in my testing so far... but this feels sketch
		LATEST=$(rclone ls $REMOTE_NAME:$REMOTE_PREFIX/pv-$VOLUME/ | tail -1 | awk '{print $2}')
		echo "Found $LATEST to be the latest snapshot..."
		rclone copy $REMOTE_NAME:$REMOTE_PREFIX/pv-$VOLUME/$LATEST /tmp/$LATEST
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted getting snapshot from s3! (rclone)"
			rm /tmp/$LATEST
			exit 1
		fi
		echo $TWOSECRET | gpg --batch --yes --passphrase-fd 0 -o /tmp/$VOLUME-restore.tar.xz -d /tmp/$LATEST
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted decrypting snapshot! (gpg)"
			rm /tmp/$LATEST
			exit 1
		fi
		rm /tmp/$LATEST
		tar -C /pvs/$VOLUME -xvf /tmp/$VOLUME-restore.tar.xz
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted extracting snapshot! (tar)"
			rm /tmp/$VOLUME-restore.tar.xz
			exit 1
		fi
		rm /tmp/$VOLUME-restore.tar.xz
		echo "Restore of ${VOLUME} completed successfully!"
		;;

	*)
		echo "Invalid action provided!"
		exit 1
		;;
esac
