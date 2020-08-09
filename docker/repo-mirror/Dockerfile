FROM alpine
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update rsync

EXPOSE 12000
ADD ./run /usr/local/bin/run
RUN chmod 755 /usr/local/bin/run

ENTRYPOINT ["/usr/local/bin/run"]
