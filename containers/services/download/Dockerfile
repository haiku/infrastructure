FROM docker.io/alpine:3.21

LABEL org.opencontainers.image.source="https://github.com/haiku/infrastructure"
LABEL org.opencontainers.image.url="https://github.com/haiku/infrastructure/tree/main/containers/services/download"
LABEL org.opencontainers.image.authors="Haiku, Inc."
LABEL org.opencontainers.image.vendor="Haiku, Inc."
LABEL org.opencontainers.image.description="cgit Interface for Haiku"

ADD requirements.txt /
ADD entry.sh /entry.sh

# TODO: Maybe we want this container to pull the generate-download-pages repo at startup instead
#       of at build time?
RUN apk add --update python3 python3-dev py-pip git libgcc curl && \
	pip install --break-system-packages -r /requirements.txt && \
	git clone https://github.com/haiku/generate-download-pages.git /generate-download-pages && \
	mkdir /generate-download-pages/output && \
	chmod 755 /entry.sh && \
	chown -R nobody:nobody /generate-download-pages/output

USER nobody
EXPOSE 8080
CMD ["/entry.sh"]
