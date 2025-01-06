FROM docker.io/alpine:3.15

MAINTAINER Haiku, Inc <haiku-inc@gmail.com>
LABEL org.opencontainers.image.source https://github.com/haiku/infrastructure
LABEL org.opencontainers.image.url https://github.com/haiku/infrastructure/tree/master/containers/tools/pgbackup
LABEL org.opencontainers.image.vendor Haiku, Inc.

RUN apk add --update bash rsync gnupg rsync xz tar postgresql14-client jq

ADD https://dl.minio.io/client/mc/release/linux-amd64/mc /usr/local/bin/mc
ADD pgsync.sh /usr/local/bin/pgsync
RUN chmod 755 /usr/local/bin/mc

ENTRYPOINT ["/usr/local/bin/pgsync"]
