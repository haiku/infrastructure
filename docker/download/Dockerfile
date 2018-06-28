FROM alpine
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update python python-dev py-pip git
RUN pip install mako boto supervisor
RUN git clone https://github.com/haiku/generate-download-pages.git /generate-download-pages
RUN mkdir /generate-download-pages/output

ADD site-generator /usr/local/bin/site-generator
RUN chmod 755 /usr/local/bin/site-generator

ADD supervisord.conf /etc/supervisord.conf

VOLUME ["/secrets"]
CMD ["/usr/bin/supervisord"]
