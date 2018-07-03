FROM alpine
MAINTAINER Haiku, Inc. <haiku.inc@gmail.com>

RUN apk add --update --no-cache nginx curl inotify-tools
RUN mkdir -p /run/nginx
COPY auto-reload.sh /bin/auto-reload
COPY entrypoint.sh /bin/entrypoint

VOLUME ["/etc/nginx/conf.d"]
CMD ["/bin/entrypoint"]
