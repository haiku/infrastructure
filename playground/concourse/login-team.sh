#!/bin/bash

# This just uses the simple test user for now.

CONCOURSE_URL="http://localhost:8080"
FLY_CLI="fly"

if [ $# -ne 1 ]; then
    echo "usage: $0 <team>"
    exit 1
fi

TEAM="$1"

echo "Please log-out of concourse in your web browser..."
read -p "Press enter to continue..."

$FLY_CLI login -t $TEAM -c $CONCOURSE_URL -n $TEAM -b 
