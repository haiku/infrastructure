#!/bin/sh

MONITOR_PATHS="/etc/nginx/conf.d"
for path in $MONITOR_PATHS; do
	echo "Auto-reload $path..."
	auto-reload $path &
done

echo "Starting nginx..."
exec nginx -g "daemon off;"
