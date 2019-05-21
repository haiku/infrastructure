#!/bin/bash

if [ $# -ne 2 ]; then
	echo "usage: $0 <branch> <secrets>"
	exit 1
fi

BRANCH="$1"
SECRETS="$2"

if [ ! -f $SECRETS ]; then
	echo "Unable to access secrets file $SECRETS!"
	exit 1
fi

. $SECRETS

if [ -z "$S3_KEY" ]; then
	echo "S3_KEY is undefined in provided secrets!"
	exit 1
fi
if [ -z "$S3_SECRET" ]; then
	echo "S3_SECRET is undefined in provided secrets!"
	exit 1
fi

CONCOURSE_URL="http://localhost:8080"
FLY_CLI=~/fly

ARCHES="x86_64 arm sparc riscv64 ppc m68k"

if [ $BRANCH == "master" ]; then
	PROFILE="nightly"
else
	PROFILE="release"
fi

echo "Flight ready for boarding. Using template: haiku-$PROFILE.yml"
for ARCH in $ARCHES; do
	$FLY_CLI -t haiku set-pipeline -n -p $BRANCH-$ARCH -v branch=$BRANCH -v arch=$ARCH -v s3key=$S3_KEY -v s3secret=$S3_SECRET -v profile=$PROFILE -c pipelines/haiku-$PROFILE.yml
done
