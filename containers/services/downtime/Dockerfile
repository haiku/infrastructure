FROM docker.io/alpine:3.14

MAINTAINER Haiku, Inc. <contact@haiku-os.org>
LABEL org.opencontainers.image.source https://github.com/haiku/infrastructure
LABEL org.opencontainers.image.url https://github.com/haiku/infrastructure/tree/master/containers/services/downtime
LABEL org.opencontainers.image.vendor Haiku, Inc.

RUN apk add nginx && mkdir /var/www/downtime && \
	echo "daemon              off;" >> /etc/nginx/nginx.conf

ADD conf/default.conf /etc/nginx/http.d/default.conf
ADD boot /boot
ADD templates /var/www/downtime

RUN chown -R nginx:www-data /var/www/downtime && chmod 755 /boot

CMD ["/boot"]
EXPOSE 80
