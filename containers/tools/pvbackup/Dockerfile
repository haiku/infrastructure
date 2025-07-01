FROM docker.io/alpine:3.21

LABEL org.opencontainers.image.source="https://github.com/haiku/infrastructure"
LABEL org.opencontainers.image.url="https://github.com/haiku/infrastructure/tree/main/containers/tools/pvbackup"
LABEL org.opencontainers.image.authors="Haiku, Inc."
LABEL org.opencontainers.image.vendor="Haiku, Inc."
LABEL org.opencontainers.image.description="pvbackup for Haiku Infrastructure"

RUN apk add --update bash rsync gnupg rsync xz tar \
  && if [ "$(uname -m)" = "x86_64" ]; then wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc; fi \
  && if [ "$(uname -m)" = "aarch64" ]; then wget https://dl.min.io/client/mc/release/linux-arm64/mc -O /usr/local/bin/mc; fi \
  && chmod 755 /usr/local/bin/mc \
  && mkdir -p /pvs

ADD pvsync.sh /usr/local/bin/pvsync
ENTRYPOINT ["/usr/local/bin/pvsync"]
