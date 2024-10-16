#!/bin/bash

if [ $# -ne 3 ]; then
	echo "usage: $0 <team> <branch> <secrets>"
	exit 1
fi

# Build on alternative physical sites
WORKER_TAG="site_av"
#WORKER_TAG="site_rl"

TEAM="$1"
BRANCH="$2"
SECRETS="$3"
COMMON_FLAGS="-n -l $SECRETS -v worker_tag=$WORKER_TAG -v branch=$BRANCH"


if [ ! -f $SECRETS ]; then
	echo "Unable to access secrets file $SECRETS!"
	exit 1
fi

FLY_CLI=fly

echo "Switching haiku target to $TEAM team..."
$FLY_CLI -t haiku edit-target -n $TEAM
if [ $? -ne 0 ]; then
	echo "Error setting haiku target to $TEAM team!"
	exit 1
fi

$FLY_CLI -t haiku status
if [ $? -ne 0 ]; then
	echo "Error setting haiku target to $TEAM team!"
	exit 1
fi

if [ $BRANCH == "r1beta4" ]; then
	BUCKET_IMAGE="haiku-release-candidates"
	BUCKET_REPO="haiku-central-repositories"
	BRANCH_PROFILE="release"
	ARCHES="x86_64 x86_gcc2h"
	DAYS="Sunday"
elif [ $BRANCH == "r1beta5" ]; then
	BUCKET_IMAGE="haiku-release-candidates"
	BUCKET_REPO="haiku-central-repositories"
	BRANCH_PROFILE="release"
	ARCHES="x86_64 x86_gcc2h"
	DAYS="Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday"
else
	BUCKET_IMAGE="haiku-nightly-us"
	BUCKET_REPO="haiku-central-repositories"
	BRANCH_PROFILE="nightly"
	#ARCHES="x86_64 x86_gcc2h arm sparc riscv64 ppc m68k"
	ARCHES="x86_64 x86_gcc2h arm sparc riscv64 m68k"
	DAYS="Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday"
fi

if [ "$TEAM" == "continuous" ]; then
	# This one is all-in-one
	$FLY_CLI -t haiku set-pipeline -p gerrit-$BRANCH $COMMON_FLAGS -c pipelines/haiku-gerrit-build.yml
	$FLY_CLI -t haiku expose-pipeline -p gerrit-$BRANCH
fi

if [ "$TEAM" != "continuous" ] && [ "$TEAM" != "bootstrap" ]; then
	echo "Deploy toolchain builder..."
	$FLY_CLI -t haiku set-pipeline -n -p toolchain-$BRANCH $COMMON_FLAGS -c pipelines/toolchain-builder.yml
	$FLY_CLI -t haiku expose-pipeline -p toolchain-$BRANCH
fi

# Anyboot is the "ideal image media type"
echo "Flight ready for boarding..."
for ARCH in $ARCHES; do
	PROFILE=$BRANCH_PROFILE
	MEDIA="anyboot"

	# Some architectures are special
	if [ "$ARCH" == "arm" ]; then
		PROFILE="minimum"
		MEDIA="mmc"
	elif [ "$ARCH" == "sparc" ]; then
		PROFILE="minimum"
		MEDIA="raw"
	elif [ "$ARCH" == "riscv64" ]; then
		PROFILE="nightly"
		MEDIA="mmc"
	elif [ "$ARCH" == "ppc" ]; then
		# TODO: PPC needs a "unified" bootable target. At the moment you build
		# haiku-boot-cd and minimum-raw to get a bootable iso + Haiku OS image.
		PROFILE="minimum"
		MEDIA="raw"
	fi

	echo "Applying $BRANCH - $ARCH target: @$PROFILE-$MEDIA"

	if [ "$TEAM" == "continuous" ]; then
		$FLY_CLI -t haiku set-pipeline -p $BRANCH-$ARCH $COMMON_FLAGS -v arch=$ARCH -v profile=$PROFILE -v media=$MEDIA -c pipelines/haiku-continuous.yml
	elif [ "$TEAM" == "bootstrap" ]; then
		$FLY_CLI -t haiku set-pipeline -p $BRANCH-$ARCH $COMMON_FLAGS -v arch=$ARCH -v profile=$PROFILE -v media=$MEDIA -c pipelines/haiku-bootstrap.yml
	else
		$FLY_CLI -t haiku set-pipeline -p $BRANCH-$ARCH $COMMON_FLAGS -v arch=$ARCH -v profile=$PROFILE -v media=$MEDIA -v bucket_image=$BUCKET_IMAGE -v bucket_repo=$BUCKET_REPO -y days=\[$DAYS\] -c pipelines/haiku-release.yml
	fi
	$FLY_CLI -t haiku expose-pipeline -p $BRANCH-$ARCH
done
