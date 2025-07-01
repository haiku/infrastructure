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

S3_NAME="s3remote"

#S3_HOST="http://s3.wasabisys.com"
#S3_BUCKET=""
#S3_KEY=""
#S3_SECRET=""
#TWOSECRET=""

if [ -z "$S3_HOST" ]; then
	echo "Please set S3_HOST!"
	exit 1
fi
if [ -z "$S3_BUCKET" ]; then
	echo "Please set S3_BUCKET!"
	exit 1
fi
if [ -z "$S3_KEY" ]; then
	echo "Please set S3_KEY!"
	exit 1
fi
if [ -z "$S3_SECRET" ]; then
	echo "Please set S3_SECRET!"
	exit 1
fi
if [ -z "$TWOSECRET" ]; then
	echo "Please set TWOBUCKET!"
	exit 1
fi

if [[ ! -d "$BASE/$VOLUME" ]]; then
	echo "Error: '$BASE/$VOLUME' isn't present on local container! (pvc not mounted?)"
	exit 1
fi

rclone config create $S3_NAME s3 \
	provider=other env_auth=false access_key_id=$S3_KEY \
	secret_access_key=$S3_SECRET region=$S3_REGION \
	endpoint=$S3_HOST force_path_style=false \
	acl=private bucket_acl=private --obscure

if [[ $? -ne 0 ]]; then
	echo "Error: Problem encounted configuring s3! (rclone)"
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
		rclone copy /tmp/$SNAPSHOT_NAME.gpg $S3_NAME:$S3_BUCKET/pv-$VOLUME/$SNAPSHOT_NAME.gpg
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted during upload! (rclone)"
			rm /tmp/$SNAPSHOT_NAME.gpg
			exit 1
		fi
		if [[ -z "$S3_MAX_AGE" ]]; then
			echo "Cleaning up old backups for $VOLUME over $S3_MAX_AGE old..."
			rclone delete --min-age "$S3_MAX_AGE" $S3_NAME:$S3_BUCKET/pv-$VOLUME/
		fi
		echo "Snapshot of ${VOLUME} completed successfully! ($S3_BUCKET/pv-$VOLUME/$SNAPSHOT_NAME.gpg)"
		;;

	restore)
		# We assume the latest is at the bottom of the rclone ls.
		# It seems to be true in my testing so far... but this feels sketch
		LATEST=$(rclone ls $S3_NAME:$S3_BUCKET/pv-$VOLUME/ | tail -1 | awk '{print $2}')
		echo "Found $LATEST to be the latest snapshot..."
		rclone copy $S3_NAME:$S3_BUCKET/pv-$VOLUME/$LATEST /tmp/$LATEST
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
