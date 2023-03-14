FROM docker.io/alpine:3.14

MAINTAINER Haiku, Inc. <contact@haiku-os.org>
LABEL org.opencontainers.image.source https://github.com/haiku/infrastructure
LABEL org.opencontainers.image.url https://github.com/haiku/infrastructure/tree/master/containers/i18n-static
LABEL org.opencontainers.image.vendor Haiku, Inc.

RUN apk add nginx && mkdir /var/www/i18n-static && \
	echo "daemon              off;" >> /etc/nginx/nginx.conf

ADD conf/default.conf /etc/nginx/http.d/default.conf
ADD www-data /var/www/i18n-static

RUN chown -R nginx:www-data /var/www/i18n-static

CMD ["nginx"]
EXPOSE 80
