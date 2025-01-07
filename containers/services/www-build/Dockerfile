FROM docker.io/nginx:alpine

LABEL org.opencontainers.image.source="https://github.com/haiku/infrastructure"
LABEL org.opencontainers.image.url="https://github.com/haiku/infrastructure/tree/main/containers/services/www-build"
LABEL org.opencontainers.image.authors="Haiku, Inc."
LABEL org.opencontainers.image.vendor="Haiku, Inc."
LABEL org.opencontainers.image.description="www-build static page for Haiku"

RUN mkdir -p /var/lib/www

COPY configs/nginx.conf /etc/nginx/conf.d/default.conf
COPY www/. /var/lib/www
