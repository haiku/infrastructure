FROM php:7.2-apache

RUN apt-get update && apt-get install -y libpq-dev git && docker-php-ext-install pdo pdo_pgsql

ENV APACHE_DOCUMENT_ROOT /var/userguide/app/userguide

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /var/userguide/