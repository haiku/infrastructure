FROM docker.io/alpine:3.22

LABEL org.opencontainers.image.source="https://github.com/haiku/infrastructure"
LABEL org.opencontainers.image.url="https://github.com/haiku/infrastructure/tree/main/containers/tools/pgbackup"
LABEL org.opencontainers.image.authors="Haiku, Inc."
LABEL org.opencontainers.image.vendor="Haiku, Inc."
LABEL org.opencontainers.image.description="pgbackup for Haiku Infrastructure"

RUN apk add --update bash rsync gnupg rclone xz tar postgresql15-client jq;

ADD pgsync.sh /usr/local/bin/pgsync
ENTRYPOINT ["/usr/local/bin/pgsync"]
