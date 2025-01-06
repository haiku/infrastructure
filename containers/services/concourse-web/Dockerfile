FROM docker.io/concourse/concourse:7.6.0

LABEL org.opencontainers.image.source https://github.com/haiku/infrastructure
LABEL org.opencontainers.image.url https://github.com/haiku/infrastructure/tree/master/containers/services/concourse-web
LABEL org.opencontainers.image.vendor Haiku, Inc.

COPY entry.sh /entry.sh
RUN chmod 755 /entry.sh
ENTRYPOINT ["/entry.sh"]
