#!/bin/bash

MIRROR_DIR=/data

if [ -z "$BACKEND" ]; then
	echo "Error: Must set BACKEND storage provider"
	exit 1
fi

echo "Configuring rclone..."
if [ "$BACKEND" = "tardigate" ]; then
	rclone config create --non-interactive $BACKEND-fs $BACKEND access_grant=$STORJ_ACCESS_GRANT satellite_address=$STORJ_SATELLITE passphrase=$STORJ_PASS
elif [ "$BACKEND" = "s3" ]; then
	rclone config create --non-interactive $BACKEND-fs $BACKEND access_key_id=$S3_ACCESS_KEY secret_access_key=$S3_SECRET_KEY endpoint=$S3_ENDPOINT
fi

echo "Testing config..."
rclone ls $BACKEND-fs:/$BUCKET
if [ $? -ne 0 ]; then
	echo "Configuration did NOT pass validation!"
	exit 1
fi

echo "Syncing..."
rclone sync $BACKEND-fs:/$BUCKET $MIRROR_DIR
