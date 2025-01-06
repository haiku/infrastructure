#!/bin/bash

MOUNT_DIR=/rclonefs

modprobe fuse
if [ $? -ne 0 ]; then
	echo "Error loading fuse module! Check for --privileged or securityContext.privileged: true"
	exit 1
fi

if [ -z "$BACKEND" ]; then
	echo "Error: Must set BACKEND storage provider"
	exit 1
fi

echo "Configuring rclone..."
if [ "$BACKEND" = "tardigate" ]; then
	rclone config create $BACKEND-fs $BACKEND access_grant=$STORJ_ACCESS_GRANT satellite_address=$STORJ_SATELLITE passphrase=$STORJ_PASS
elif [ "$BACKEND" = "s3" ]; then
	rclone config create $BACKEND-fs $BACKEND access_key_id=$S3_ACCESS_KEY secret_access_key=$S3_SECRET_KEY endpoint=$S3_ENDPOINT
fi

echo "Testing config..."
rclone ls storj:/$BUCKET
if [ $? -ne 0 ]; then
	echo "Configuration did NOT pass validation!"
	exit 1
fi

echo "Mounting..."
rclone mount $BACKEND-fs:/$BUCKET:./ $MOUNT_DIR
