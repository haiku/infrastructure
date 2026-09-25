FROM alpine
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update git python3 py3-pip wget curl lighttpd
RUN pip3 install supervisor boto3

ADD update-ports-mirror /usr/local/bin/update-ports-mirror
ADD lighttpd.conf /etc/lighttpd.conf
ADD supervisord.conf /etc/supervisord.conf

VOLUME ["/ports-mirror"]
CMD ["/usr/bin/supervisord"]
