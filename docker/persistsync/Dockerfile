FROM alpine
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update bash rsync gnupg rsync xz tar

ADD https://dl.minio.io/client/mc/release/linux-amd64/mc /usr/local/bin/mc
ADD pvsync.sh /usr/local/bin/pvsync
RUN chmod 755 /usr/local/bin/mc
RUN mkdir -p /pvs

ENTRYPOINT ["/usr/local/bin/pvsync"]
