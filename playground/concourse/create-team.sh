#!/bin/bash

FLY_CLI="fly"

if [ $# -ne 2 ]; then
    echo "usage: $0 <team> <secrets>"
    exit 1
fi

TEAM="$1"
. $2

$FLY_CLI login -t main -c $CONCOURSE_URL -n $FLY_LOCAL_TEAM -b -u $FLY_LOCAL_USERNAME -p $FLY_LOCAL_PASSWORD
$FLY_CLI -t main set-team -n $TEAM --local-user=$FLY_LOCAL_USERNAME --non-interactive
$FLY_CLI login -t $TEAM -c $CONCOURSE_URL -n $TEAM -b -u $FLY_LOCAL_USERNAME -p $FLY_LOCAL_PASSWORD
