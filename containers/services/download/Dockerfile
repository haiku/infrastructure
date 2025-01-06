FROM docker.io/alpine:3.15

MAINTAINER Haiku, Inc. <contact@haiku-os.org>
LABEL org.opencontainers.image.source https://github.com/haiku/infrastructure
LABEL org.opencontainers.image.url https://github.com/haiku/infrastructure/tree/master/containers/services/download
LABEL org.opencontainers.image.vendor Haiku, Inc.

ADD requirements.txt /
ADD entry.sh /entry.sh

RUN apk add --update python3 python3-dev py-pip git libgcc curl && \
	pip install -r /requirements.txt && \
	git clone https://github.com/haiku/generate-download-pages.git /generate-download-pages && \
	mkdir /generate-download-pages/output && \
	chmod 755 /entry.sh && \
	chown -R nobody:nobody /generate-download-pages/output

USER nobody

EXPOSE 8080

CMD ["/entry.sh"]
