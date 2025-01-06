#!/bin/sh

if [ ! -f ${CONFIG_PATH} ]; then
	echo "Missing s3 secrets at ${CONFIG_PATH}!"
	exit 1
fi

echo "Starting webserver..."
cd /generate-download-pages/output && /usr/bin/python3 -m http.server 8080 &

echo "Starting download page generator loop..."
cd /generate-download-pages
while true; do
	echo "generate-download-pages.py running..."
	/usr/bin/python3 /generate-download-pages/generate-download-pages.py --config ${CONFIG_PATH}
	sleep 1800
done
