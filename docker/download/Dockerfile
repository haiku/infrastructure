FROM alpine
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update python python-dev py-pip git libgcc
RUN pip install mako boto supervisor
RUN git clone https://github.com/haiku/generate-download-pages.git /generate-download-pages
RUN mkdir /generate-download-pages/output

ADD site-generator /usr/local/bin/site-generator
RUN chmod 755 /usr/local/bin/site-generator

ADD https://gitlab.com/kallisti5/symlinkbot/uploads/e3063765250db20bfedaef35fbb2d2cd/symlinkbot-musl /usr/local/bin/symlinkbot
RUN chmod 755 /usr/local/bin/symlinkbot

ADD supervisord.conf /etc/supervisord.conf

VOLUME ["/secrets", "/data"]
CMD ["/usr/bin/supervisord"]
