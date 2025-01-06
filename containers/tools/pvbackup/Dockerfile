FROM alpine

MAINTAINER Haiku, Inc <haiku-inc@gmail.com>
LABEL org.opencontainers.image.source https://github.com/haiku/infrastructure
LABEL org.opencontainers.image.url https://github.com/haiku/infrastructure/tree/master/containers/tools/pvbackup
LABEL org.opencontainers.image.vendor Haiku, Inc.

RUN apk add --update bash rsync gnupg rsync xz tar

ADD https://dl.minio.io/client/mc/release/linux-amd64/mc /usr/local/bin/mc
ADD pvsync.sh /usr/local/bin/pvsync
RUN chmod 755 /usr/local/bin/mc
RUN mkdir -p /pvs

ENTRYPOINT ["/usr/local/bin/pvsync"]
