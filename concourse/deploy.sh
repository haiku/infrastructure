#!/bin/bash

CONCOURSE_URL="https://ci.haiku-os.org"

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <secrets>"
	exit 1
fi

# Logout if we're logged in
fly -t haiku status
if [[ $? -eq 0 ]]; then
	echo "Logging out old session..."
	fly -t haiku delete-target
fi

# Login to the continious team
fly -t haiku login -c $CONCOURSE_URL -n continuous -b

## Deploy pipelines
## continuous team.  Builds on every commit. Artifacts not saved
fly -t haiku set-team -n continuous --github-team=haiku:infrastructure --non-interactive
./apply-pipeline.sh continuous master $1

## nightly team.  Builds releases every night. Artifacts pushed to nightly bucket
fly -t haiku set-team -n nightly --github-team=haiku:infrastructure --non-interactive
./apply-pipeline.sh nightly master $1

## r1beta1 team. Builds released weekly. Artifacts pushed to release buckets
fly -t haiku set-team -n r1beta1 --github-team=haiku:infrastructure --non-interactive
./apply-pipeline.sh r1beta1 r1beta1 $1

## r1beta2 team. Builds released weekly. Artifacts pushed to release buckets
fly -t haiku set-team -n r1beta2 --github-team=haiku:infrastructure --non-interactive
./apply-pipeline.sh r1beta2 r1beta2 $1
