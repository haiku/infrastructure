#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "Backup / Restore Postgresql data"
	echo "Usage: $0 [backup|restore] <db_name>"
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


ACTION="$1"
DATABASE="$2"

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

# Database config
if [ -z "$PG_HOSTNAME" ]; then
	echo "Please set TWOBUCKET!"
	exit 1
fi
if [ -z "$PG_PORT" ]; then
	export PG_PORT=5432
fi
if [ -z "$PG_DBNAME" ]; then
	echo "Please set PG_DBNAME!"
	exit 1
fi
if [ -z "$PG_USERNAME" ]; then
	echo "Please set PG_USERNAME!"
	exit 1
fi
if [ -z "$PG_PASSWORD" ]; then
	echo "Please set PG_PASSWORD!"
	exit 1
fi

# Write out our secrets
echo "$PG_HOSTNAME:$PG_PORT:$PG_DBNAME:$PG_USERNAME:$PG_PASSWORD" > ~/.pgpass
chmod 600 ~/.pgpass

case $ACTION in
	backup)
		SNAPSHOT_NAME=${DATABASE}_$(date +"%Y-%m-%d").tar.xz
		echo "Backup ${DATABASE}..."
		cd /tmp
		pg_dump -U $PG_USERNAME $PG_DBNAME | xz > /tmp/$SNAPSHOT_NAME
		if [[ $? -ne 0 ]]; then
			rm -f ~/.pgpass
			echo "Error: Problem encounted performing snapshot!"
			exit 1
		fi
		rm -f ~/.pgpass
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
		mc cp /tmp/$SNAPSHOT_NAME.gpg $S3_NAME/$S3_BUCKET/$PG_DBNAME/$SNAPSHOT_NAME.gpg
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted during upload! (mc)"
			rm /tmp/$SNAPSHOT_NAME.gpg
			exit 1
		fi
		if [[ -z "$S3_MAX_AGE" ]]; then
			echo "Cleaning up old backups for database $PG_DBNAME over $S3_MAX_AGE old..."
			mc find $S3_NAME/$S3_BUCKET/$PG_DBNAME/ --older-than "$S3_MAX_AGE" --exec "mc rm {}"
		fi
		echo "Snapshot of ${PG_DBNAME} completed successfully! ($S3_BUCKET/$PG_DBNAME/$SNAPSHOT_NAME.gpg)"
		;;

	restore)
		mc config host add $S3_NAME $S3_HOST $S3_KEY $S3_SECRET --api "s3v4"
		if [[ $? -ne 0 ]]; then
			rm -f ~/.pgpass
			echo "Error: Problem encounted configuring s3! (mc)"
			exit 1
		fi
		# We assume the latest is at the bottom of the mc ls.
		# It seems to be true in my testing so far... but this feels sketch
		LATEST=$(mc ls -q $S3_NAME/$S3_BUCKET/$PG_DBNAME/ | tail -1 | awk '{ print $5 }')
		echo "Found $LATEST to be the latest snapshot..."
		mc cp $S3_NAME/$S3_BUCKET/$PG_DBNAME/$LATEST /tmp/$LATEST
		if [[ $? -ne 0 ]]; then
			rm -f ~/.pgpass
			echo "Error: Problem encounted getting snapshot from s3! (mc)"
			rm /tmp/$LATEST
			exit 1
		fi
		echo $TWOSECRET | gpg --batch --yes --passphrase-fd 0 -o /tmp/$PG_DBNAME-restore.sql.xz -d /tmp/$LATEST
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted decrypting snapshot! (gpg)"
			rm -f ~/.pgpass
			rm /tmp/$LATEST
			exit 1
		fi
		rm /tmp/$LATEST
		xz -cd /tmp/$PG_DBNAME-restore.sql.xz | pg_restore -h $PG_HOSTNAME -U $PG_USERNAME $PG_DBNAME
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted extracting snapshot! (tar)"
			rm -f ~/.pgpass
			rm /tmp/$PG_DBNAME-restore.tar.xz
			exit 1
		fi
		rm /tmp/$PG_DBNAME-restore.tar.xz
		rm -f ~/.pgpass
		echo "Restore of ${PG_DBNAME} completed successfully!"
		;;

	*)
		echo "Invalid action provided!"
		exit 1
		;;
esac
