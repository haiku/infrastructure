FROM docker.io/alpine:3.22

LABEL org.opencontainers.image.source="https://github.com/haiku/infrastructure"
LABEL org.opencontainers.image.url="https://github.com/haiku/infrastructure/tree/main/containers/tools/pvbackup"
LABEL org.opencontainers.image.authors="Haiku, Inc."
LABEL org.opencontainers.image.vendor="Haiku, Inc."
LABEL org.opencontainers.image.description="pvbackup for Haiku Infrastructure"

RUN apk add --update bash rsync gnupg rsync xz tar rclone \
  && mkdir -p /pvs

ADD pvsync.sh /usr/local/bin/pvsync
ENTRYPOINT ["/usr/local/bin/pvsync"]
