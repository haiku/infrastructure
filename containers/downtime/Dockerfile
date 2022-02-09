FROM docker.io/alpine:3.14

RUN apk add nginx && mkdir /var/www/downtime && \
	echo "daemon              off;" >> /etc/nginx/nginx.conf

ADD conf/default.conf /etc/nginx/http.d/default.conf
ADD boot /boot
ADD templates /var/www/downtime

RUN chown -R nginx:www-data /var/www/downtime && chmod 755 /boot

CMD ["/boot"]
EXPOSE 80
