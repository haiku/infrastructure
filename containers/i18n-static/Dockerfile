FROM docker.io/alpine:3.14

RUN apk add nginx && mkdir /var/www/i18n-static && \
	echo "daemon              off;" >> /etc/nginx/nginx.conf

ADD conf/default.conf /etc/nginx/http.d/default.conf
ADD www-data /var/www/i18n-static

RUN chown -R nginx:www-data /var/www/i18n-static

CMD ["nginx"]
EXPOSE 80
