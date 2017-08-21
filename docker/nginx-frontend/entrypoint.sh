#!/bin/sh

auto-reload /etc/nginx/nginx.conf &
auto-reload /haiku-files/nightly-images/currentImages.map.nginx &

exec nginx -g "daemon off;"
