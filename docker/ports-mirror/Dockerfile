FROM alpine
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update git python python-dev curl py-pip libgcc
RUN pip install mako boto supervisor toml

ADD update-ports-mirror /usr/local/bin/update-ports-mirror
ADD supervisord.conf /etc/supervisord.conf

VOLUME ["/ports-mirror"]
CMD ["/usr/bin/supervisord"]
