#!/bin/bash

# This just uses the simple test user for now.

CONCOURSE_URL="http://localhost:8080"
FLY_CLI="/home/kallisti5/fly"
BRANCH="$1"

$FLY_CLI login -t main -c $CONCOURSE_URL -n main -b
$FLY_CLI -t main set-team -n haiku --local-user=test
$FLY_CLI login -t haiku -c $CONCOURSE_URL -n haiku -b
