FROM alpine:latest
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk update && apk add cgit lighttpd git

COPY assets/cgit.conf /etc/lighttpd/cgit.conf
COPY assets/cgitrc /etc/cgitrc
COPY assets/haiku-cgit.css /usr/share/webapps/cgit/haiku-cgit.css
COPY assets/haiku-logo.png /usr/share/webapps/cgit/haiku-logo.png
RUN echo 'include "cgit.conf"' >> /etc/lighttpd/lighttpd.conf

RUN rm -rf /var/cache/apk/*

EXPOSE 80
VOLUME /var/git

ENTRYPOINT ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
