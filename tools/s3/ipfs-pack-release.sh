#!/bin/bash
set -e

S3="/s3/haiku-release"
CAR_CACHE="/var/lib/private/garage/cars"

if [ $# -lt 1 ]; then
	echo "usage: $0 <release>"
	echo ""
	echo "release - name of the release within the $BUCKET bucket"
	exit 1
fi
RELEASE=$1

mkdir -p $CAR_CACHE

echo "Cleaning up old car files..."
rm -f $CAR_CACHE/haiku-${RELEASE}.car

echo "Packing $RELEASE into an IPFS car..."
# pack the contents of this release into a car file
npx ipfs-car pack $S3/$RELEASE -o $CAR_CACHE/haiku-${RELEASE}.car

CID=$(npx ipfs-car ls $CAR_CACHE/haiku-${RELEASE}.car --verbose | head -1 | awk '{ print $1 }')

echo "Get $CAR_CACHE/haiku-${RELEASE}.car, and import it to your IPFS node via:"
echo "$ ipfs dag import .../haiku-${RELEASE}.car"
echo "The ${RELEASE} release can be added to your IPFS MFS via:"
echo "$ ipfs files cp /ipfs/$CID /haiku/releases/${RELEASE}"
