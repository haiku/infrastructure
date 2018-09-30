FROM alpine
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update python python-dev py-pip git libgcc
RUN pip install mako boto supervisor toml
RUN git clone https://github.com/haiku/generate-download-pages.git /generate-download-pages
RUN mkdir /generate-download-pages/output

ADD site-generator /usr/local/bin/site-generator
RUN chmod 755 /usr/local/bin/site-generator

ADD https://gitlab.com/kallisti5/symlinkbot/uploads/67fa87370323b10ca8ad0d00da57f86f/symlinkbot-linux_musl-x86_64 /usr/local/bin/symlinkbot
RUN chmod 755 /usr/local/bin/symlinkbot

ADD supervisord.conf /etc/supervisord.conf

VOLUME ["/secrets", "/data"]
CMD ["/usr/bin/supervisord"]
