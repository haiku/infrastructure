FROM alpine:latest
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update git python curl

ADD update-ports-mirror /usr/local/bin/update-ports-mirror

VOLUME ["/ports-mirror"]

ENTRYPOINT ["/usr/local/bin/update-ports-mirror"]
