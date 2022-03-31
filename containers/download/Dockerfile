FROM docker.io/alpine:3.15
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

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
HEALTHCHECK --start-period=3m --retries=2 CMD curl --fail http://`hostname`:8080/ || exit 1

CMD ["/entry.sh"]
