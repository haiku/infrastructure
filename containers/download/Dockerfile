FROM docker.io/alpine
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

ADD requirements.txt /

RUN apk add --update python3 python3-dev py-pip git libgcc curl
RUN pip install -r /requirements.txt
RUN git clone https://github.com/haiku/generate-download-pages.git /generate-download-pages
RUN mkdir /generate-download-pages/output

ADD site-generator /usr/local/bin/site-generator
RUN chmod 755 /usr/local/bin/site-generator

ADD supervisord.conf /etc/supervisord.conf

EXPOSE 80
HEALTHCHECK --start-period=3m --retries=2 CMD curl --fail http://`hostname`:80/ || exit 1

VOLUME ["/secrets", "/data"]
CMD ["/usr/bin/supervisord"]
