#!/bin/sh

# store filename and extension in local vars
BASENAME="$1"
EXTENSION="${BASENAME##*.}"

exec markdown 2>/dev/null
