FROM alpine:latest
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update \
    tini gettext curl fcgiwrap spawn-fcgi git cgit highlight perl nginx discount groff py-pip
RUN pip install docutils

ENTRYPOINT ["/sbin/tini", "--"]

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

RUN rmdir /var/git && mkdir /var/git
RUN mkdir /run/nginx

VOLUME ["/var/git"]
#VOLUME ["/var/cache/cgit"]

COPY assets/cgitrc.template /etc/
COPY assets/syntax-highlighting.sh /usr/lib/cgit/filters/
COPY assets/commit-link-filter.sh /usr/lib/cgit/filters/
COPY assets/markdown-render.sh /usr/lib/cgit/filters/
COPY assets/haiku-cgit.css /usr/share/cgit/haiku-cgit.css
COPY assets/haiku-logo.png /usr/share/cgit/haiku-logo.png

COPY assets/default.conf /etc/nginx/conf.d/default.conf
COPY assets/404.html /usr/share/nginx/html/
COPY assets/401.html /usr/share/nginx/html/
COPY assets/startup /

CMD ["/startup"]

ENV CGIT_TITLE "cgit interface"
ENV CGIT_DESC "cgit under docker"
ENV CGIT_VROOT "/"
ENV CGIT_SECTION_FROM_STARTPATH 0

HEALTHCHECK CMD curl --fail http://`hostname`:80/ || exit 1
