FROM richarvey/nginx-php-fpm:latest

# Install the requirements
RUN apk update && \
    apk add postgresql-dev

RUN docker-php-ext-install pdo pdo_pgsql

ENV WEBROOT='/var/userguide/app/userguide'