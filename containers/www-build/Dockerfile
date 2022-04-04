FROM docker.io/nginx:alpine
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN mkdir -p /var/lib/www

COPY configs/nginx.conf /etc/nginx/conf.d/default.conf
COPY www/. /var/lib/www
