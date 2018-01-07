FROM alpine:latest
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update git python curl

ADD scripts/update-ports-mirror /usr/local/bin/update-ports-mirror
RUN chmod +x //usr/local/bin/update-ports-mirror

VOLUME ["/ports-mirror"]

ENTRYPOINT ["/usr/local/bin/update-ports-mirror"]
