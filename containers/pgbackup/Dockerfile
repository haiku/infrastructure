FROM docker.io/alpine:3.15
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update bash rsync gnupg rsync xz tar postgresql14-client

ADD https://dl.minio.io/client/mc/release/linux-amd64/mc /usr/local/bin/mc
ADD pgsync.sh /usr/local/bin/pgsync
RUN chmod 755 /usr/local/bin/mc

ENTRYPOINT ["/usr/local/bin/pgsync"]
