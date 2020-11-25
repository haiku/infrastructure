#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "Backup / Restore persistant volume data"
	echo "Usage: $0 [backup|restore] <pv_name>"
	exit 1
fi

if ! [ -x "$(command -v mc)" ]; then
  echo 'Error: mc is not installed.' >&2
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
S3_HOST="http://s3.wasabisys.com"

#S3_BUCKET="persistent-snapshots"
#S3_KEY=""
#S3_SECRET=""
#TWOSECRET=""

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

case $ACTION in
	backup)
		SNAPSHOT_NAME=${VOLUME}_$(date +"%Y-%m-%d").tar.xz
		echo "Snapshot ${VOLUME}..."
		cd $BASE/$VOLUME
		tar -cvJf /tmp/$SNAPSHOT_NAME --exclude 'tmp/*' *
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
		mc config host add $S3_NAME $S3_HOST $S3_KEY $S3_SECRET --api "s3v4"
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted configuring s3! (mc)"
			rm /tmp/$SNAPSHOT_NAME.gpg
			exit 1
		fi
		mc cp /tmp/$SNAPSHOT_NAME.gpg $S3_NAME/$S3_BUCKET/$VOLUME/$SNAPSHOT_NAME.gpg
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted during upload! (mc)"
			rm /tmp/$SNAPSHOT_NAME.gpg
			exit 1
		fi
		echo "Snapshot of ${VOLUME} completed successfully! ($S3_BUCKET/$VOLUME/$SNAPSHOT_NAME.gpg)"
		;;

	restore)
		mc config host add $S3_NAME $S3_HOST $S3_KEY $S3_SECRET --api "s3v4"
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted configuring s3! (mc)"
			exit 1
		fi
		# We assume the latest is at the bottom of the mc ls.
		# It seems to be true in my testing so far... but this feels sketch
		LATEST=$(mc ls -q $S3_NAME/$S3_BUCKET/$VOLUME/ | tail -1 | awk '{ print $5 }')
		echo "Found $LATEST to be the latest snapshot..."
		mc cp $S3_NAME/$S3_BUCKET/$VOLUME/$LATEST /tmp/$LATEST
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted getting snapshot from s3! (mc)"
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
