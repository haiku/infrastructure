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

FLY_CLI=fly

if [ $BRANCH == "r1beta1" ]; then
	BUCKET="haiku-release-test"
	BRANCH_PROFILE="release"
	ARCHES="x86_64 x86_gcc2h"
	DAYS="Sunday"
elif [ $BRANCH == "r1beta2" ]; then
	BUCKET="haiku-release-test"
	BRANCH_PROFILE="release"
	ARCHES="x86_64 x86_gcc2h"
	DAYS="Monday,Friday"
else
	BUCKET="haiku-nightly-test"
	BRANCH_PROFILE="nightly"
	ARCHES="x86_64 x86_gcc2h arm sparc riscv64 ppc m68k"
	DAYS="Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday"
fi

if [ "$TEAM" != "continuous" ]; then
	echo "Deploy toolchain builder..."
	$FLY_CLI -t $TEAM set-pipeline -n -p toolchain-$BRANCH -v branch=$BRANCH -l $SECRETS -c pipelines/toolchain-builder.yml
	$FLY_CLI -t $TEAM expose-pipeline -p toolchain-$BRANCH
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
	fi

	echo "Applying $BRANCH - $ARCH target: @$PROFILE-$TYPE"

	if [ "$TEAM" == "continuous" ]; then
		$FLY_CLI -t $TEAM set-pipeline -n -p $BRANCH-$ARCH -v branch=$BRANCH -v arch=$ARCH -l $SECRETS -v profile=$PROFILE -v media=$MEDIA -c pipelines/haiku-continuous.yml
	else
		$FLY_CLI -t $TEAM set-pipeline -n -p $BRANCH-$ARCH -v branch=$BRANCH -v arch=$ARCH -l $SECRETS -v profile=$PROFILE -v media=$MEDIA -v bucket=$BUCKET -y days=\[$DAYS\] -c pipelines/haiku-release.yml
	fi
	$FLY_CLI -t $TEAM expose-pipeline -p $BRANCH-$ARCH
done
