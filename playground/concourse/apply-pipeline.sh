#!/bin/bash

if [ $# -ne 3 ]; then
	echo "usage: $0 <team> <branch> <secrets>"
	exit 1
fi

TEAM="$1"
BRANCH="$2"
SECRETS="$3"

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
if [ -z "$S3_ENDPOINT" ]; then
	echo "S3_ENDPOINT is undefined in provided secrets!"
	exit 1
fi
if [ -z "$DOCKER_HUB_USER" ]; then
	echo "DOCKER_HUB_USER is undefined in provided secrets!"
	exit 1
fi
if [ -z "$DOCKER_HUB_PASSWORD" ]; then
	echo "DOCKER_HUB_USER is undefined in provided secrets!"
	exit 1
fi

FLY_CLI=fly

if [ $BRANCH == "master" ]; then
	PROFILE="nightly"
	ARCHES="x86_64 x86_gcc2h arm sparc riscv64 ppc m68k"
else
	PROFILE="release"
	ARCHES="x86_64 x86_gcc2h"
fi


if [ "$TEAM" != "continuous" ]; then
	echo "Deploy toolchain builder..."
	$FLY_CLI -t $TEAM set-pipeline -n -p toolchain-$BRANCH -v branch=$BRANCH -v docker-hub-user=$DOCKER_HUB_USER -v docker-hub-password=$DOCKER_HUB_PASSWORD -c pipelines/toolchain-builder.yml
	$FLY_CLI -t $TEAM expose-pipeline -p toolchain-$BRANCH
fi

# Anyboot is the "ideal image type"
TYPE="anyboot"
echo "Flight ready for boarding..."
for ARCH in $ARCHES; do

	# Some architectures are special
	if [ "$ARCH" == "arm" ]; then
		PROFILE="minimal"
		TYPE="mmc"
	fi

	if [ "$TEAM" == "continuous" ]; then
		$FLY_CLI -t $TEAM set-pipeline -n -p $BRANCH-$ARCH -v branch=$BRANCH -v arch=$ARCH -v s3endpoint=$S3_ENDPOINT -v s3key=$S3_KEY -v s3secret=$S3_SECRET -v profile=$PROFILE -v type=$TYPE -c pipelines/haiku-continuous.yml
	else
		$FLY_CLI -t $TEAM set-pipeline -n -p $BRANCH-$ARCH -v branch=$BRANCH -v arch=$ARCH -v s3endpoint=$S3_ENDPOINT -v s3key=$S3_KEY -v s3secret=$S3_SECRET -v profile=$PROFILE -v type=$TYPE -c pipelines/haiku-release.yml
	fi
	$FLY_CLI -t $TEAM expose-pipeline -p $BRANCH-$ARCH
done
