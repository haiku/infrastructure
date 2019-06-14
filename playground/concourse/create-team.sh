#!/bin/bash

# This just uses the simple test user for now.

CONCOURSE_URL="http://localhost:8080"
FLY_CLI="fly"

if [ $# -ne 2 ]; then
    echo "usage: $0 <username> <team>"
    exit 1
fi

USERNAME="$1"
TEAM="$2"

# Login to main

$FLY_CLI login -t main -c $CONCOURSE_URL -n main -b -u $USERNAME
$FLY_CLI -t main set-team -n $TEAM --local-user=$USERNAME --non-interactive

echo "Please log-out of concourse in your web browser..."
read -p "Press enter to continue..."

$FLY_CLI login -t $TEAM -c $CONCOURSE_URL -n $TEAM -b -u $USERNAME 
