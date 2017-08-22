#!/bin/sh

for path in $MONITOR_PATHS; do
	echo "Auto-reload $path..."
	auto-reload $path &
done

echo "Starting nginx..."
exec nginx -g "daemon off;"
