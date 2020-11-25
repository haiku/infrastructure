FROM alpine:latest
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

ENV BUILD_PACKAGES "make asciidoc python-dev xmlto"

RUN apk add --update git python $BUILD_PACKAGES  &&\
	git clone https://gitlab.com/esr/irker.git && \
	cd irker && \
	make && make install && \
	apk del $BUILD_PACKAGES

EXPOSE 6659
ENTRYPOINT ["/usr/bin/irkerd", "-dinfo", "-nHAIKU-irker%03d", "-l/dev/stdout", "-H0.0.0.0"]
HEALTHCHECK CMD nc -z -v `hostname` 6659 2>&1 | grep open || exit 1
