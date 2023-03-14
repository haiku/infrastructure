FROM docker.io/nginx:alpine
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

LABEL org.opencontainers.image.source https://github.com/haiku/infrastructure
LABEL org.opencontainers.image.url https://github.com/haiku/infrastructure/tree/master/containers/www-build
LABEL org.opencontainers.image.vendor Haiku, Inc.

RUN mkdir -p /var/lib/www

COPY configs/nginx.conf /etc/nginx/conf.d/default.conf
COPY www/. /var/lib/www
