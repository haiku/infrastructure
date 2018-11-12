FROM debian:testing
ENV DEBIAN_FRONTEND noninteractive
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apt-get -qq update && \
    apt-get upgrade -qy && \
    apt-get -qy install apt-utils gettext-base curl \
                        fcgiwrap git cgit highlight perl \
                        ca-certificates nginx gettext-base \
                        markdown python-docutils groff && \
    echo 'UTC' > /etc/timezone && \
    dpkg-reconfigure tzdata && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add Tini
ENV TINI_VERSION v0.13.2
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN useradd nginx

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

RUN mkdir /var/git

VOLUME ["/var/git"]
#VOLUME ["/var/cache/cgit"]

COPY assets/cgitrc.template /etc/
COPY assets/syntax-highlighting.sh /usr/lib/cgit/filters/
COPY assets/commit-link-filter.sh /usr/lib/cgit/filters/
COPY assets/haiku-cgit.css /usr/share/cgit/haiku-cgit.css
COPY assets/haiku-logo.png /usr/share/cgit/haiku-logo.png

COPY assets/default.conf /etc/nginx/sites-available/default
COPY assets/404.html /usr/share/nginx/html/
COPY assets/401.html /usr/share/nginx/html/
COPY assets/startup /

CMD ["/startup"]

ENV CGIT_TITLE "My cgit interface"
ENV CGIT_DESC "cgit under docker"
ENV CGIT_VROOT "/"
ENV CGIT_SECTION_FROM_STARTPATH 0

HEALTHCHECK CMD curl --fail http://`hostname`:80/ || exit 1
