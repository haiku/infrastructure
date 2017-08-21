#!/bin/sh

while true
do
	inotifywait --exclude .swp -e create -e modify -e delete -e move $1
	nginx -t
	if [ $? -eq 0 ]
	then
		echo "reloading nginx configuration"
		nginx -s reload
	fi
done
