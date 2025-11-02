#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "Backup / Restore Postgresql data"
	echo "Usage: $0 [backup|restore] <db_name>"
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

# This function will expect the `PG_EXCLUDE_TABLE_DATA_TABLES` argument to carry a
# comma-separated list of tables. These are then split up into arguments for use
# with `pg_dump`.

function pg_exclude_table_data_args()
{
  local table_patterns

  IFS=',' read -r -a table_patterns <<< "${PG_EXCLUDE_TABLE_DATA_TABLES}"

  for table in "${table_patterns[@]}"; do
      echo -n " --exclude-table-data ${table}"
  done
}

ACTION="$1"
PG_DBNAME="$2"

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

if [ -z "$REMOTE_PREFIX" ] ;then
	echo "REMOTE_PREFIX is not defined!  This is the bucket name for s3 or other prefix path"
	exit 1
fi

if [ -z "$REMOTE_NAME" ] ;then
	echo "REMOTE_NAME is not defined. Defaulting to 'backup' (make sure this matches config file)"
	REMOTE_NAME="backup"
fi

if [[ ! -d "$BASE/$VOLUME" ]]; then
	echo "Error: '$BASE/$VOLUME' isn't present on local container! (pvc not mounted?)"
	exit 1
fi

# Database config
if [ -z "$PG_HOSTNAME" ]; then
	echo "Please set PG_HOSTNAME!"
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

REMOTE="$REMOTE_NAME:$REMOTE_PREFIX/pg-$PG_DBNAME"
rclone ls $REMOTE > /dev/null
if [ $? -ne 0 ]; then
    echo "Error: Unable to see within configured storage provider!"
    exit 1
fi

# Write out our secrets
echo "$PG_HOSTNAME:$PG_PORT:*:$PG_USERNAME:$PG_PASSWORD" > ~/.pgpass
chmod 600 ~/.pgpass

case $ACTION in
	backup)
		SNAPSHOT_NAME=${PG_DBNAME}_$(date +"%Y-%m-%d").sql.xz
		echo "Backup ${PG_DBNAME} to ${REMOTE}/$SNAPSHOT_NAME..."
		cd /tmp
		export XZ_DEFAULTS="-2"
		pg_dump -C -h "${PG_HOSTNAME}" -p "${PG_PORT}" -d "${PG_DBNAME}" -U "${PG_USERNAME}" $(pg_exclude_table_data_args) | xz > "/tmp/${SNAPSHOT_NAME}"
		if [[ $? -ne 0 ]]; then
			rm -f ~/.pgpass
			echo "Error: Problem encountered performing snapshot!"
			exit 1
		fi
		rm -f ~/.pgpass
		cat $TWOSECRET_PATH | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo TWOFISH /tmp/$SNAPSHOT_NAME
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encountered performing encryption! (gpg)"
			rm /tmp/$SNAPSHOT_NAME
			exit 1
		fi
		rm /tmp/$SNAPSHOT_NAME
		rclone copy /tmp/$SNAPSHOT_NAME.gpg $REMOTE/
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encounted during upload! (rclone)"
			rm /tmp/$SNAPSHOT_NAME.gpg
			exit 1
		fi
		if [[ ! -z "$REMOTE_MAX_AGE" ]]; then
			echo "Cleaning up old backups for database $PG_DBNAME over $REMOTE_MAX_AGE old..."
			rclone delete --min-age "$REMOTE_MAX_AGE" $REMOTE/
		fi
		echo "Snapshot of ${PG_DBNAME} completed successfully! ($REMOTE_PREFIX/pg-$PG_DBNAME/$SNAPSHOT_NAME.gpg)"
		;;

	restore)
		LATEST=$(rclone lsjson $REMOTE | jq '. |= sort_by(.ModTime) | last.Name')
		echo "Found $LATEST to be the latest snapshot..."
		rclone copy $REMOTE/$LATEST /tmp/
		if [[ $? -ne 0 ]]; then
			rm -f ~/.pgpass
			echo "Error: Problem encountered getting snapshot from s3! (mc)"
			rm /tmp/$LATEST
			exit 1
		fi
		echo $TWOSECRET | gpg --batch --yes --passphrase-fd 0 -o /tmp/$PG_DBNAME-restore.sql.xz -d /tmp/$LATEST
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encountered decrypting snapshot! (gpg)"
			rm -f ~/.pgpass
			rm /tmp/$LATEST
			exit 1
		fi
		rm /tmp/$LATEST
		xz -cd /tmp/$PG_DBNAME-restore.sql.xz | psql -h $PG_HOSTNAME -U $PG_USERNAME
		if [[ $? -ne 0 ]]; then
			echo "Error: Problem encountered extracting snapshot! (sql)"
			rm -f ~/.pgpass
			rm /tmp/$PG_DBNAME-restore.sql.xz
			exit 1
		fi
		rm /tmp/$PG_DBNAME-restore.sql.xz
		rm -f ~/.pgpass
		echo "Restore of ${PG_DBNAME} completed successfully!"
		;;

	*)
		echo "Invalid action provided!"
		exit 1
		;;
esac
