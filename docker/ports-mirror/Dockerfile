FROM alpine
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update git python py-pip wget curl lighttpd
RUN pip install supervisor

ADD update-ports-mirror /usr/local/bin/update-ports-mirror
ADD lighttpd.conf /etc/lighttpd.conf
ADD supervisord.conf /etc/supervisord.conf

VOLUME ["/ports-mirror"]
CMD ["/usr/bin/supervisord"]
