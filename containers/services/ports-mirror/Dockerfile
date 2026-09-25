FROM alpine
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update git python3 py3-pip wget curl
RUN pip3 install boto3 --break-system-packages

ADD update-ports-mirror /usr/local/bin/update-ports-mirror

VOLUME ["/ports-mirror"]
CMD ["/usr/local/bin/update-ports-mirror"]
