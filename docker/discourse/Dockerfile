#
# A sane discourse container without the "meta-build" and "launcher"
#
FROM ruby:latest

MAINTAINER Haiku, Inc. <contact@haiku-os.org>

ENV DISCOURSE_VERSION=2.3.2

RUN apt-get update && apt-get install -y git bash build-essential postgresql-client python python-pip cron nginx && pip install supervisor
RUN rm /etc/nginx/sites-enabled/default && mkdir -p /var/nginx && chown www-data:www-data /var/nginx

# Install Discourse
ADD https://github.com/discourse/discourse/archive/v$DISCOURSE_VERSION.tar.gz /release.tar.gz
RUN mkdir -p /apps && cd /apps && tar xvf /release.tar.gz && rm /release.tar.gz && mv /apps/discourse-$DISCOURSE_VERSION /apps/discourse
RUN cd /apps/discourse && bundle install

COPY supervisord.conf /etc/supervisord.conf
COPY init /init
RUN chmod 755 /init
COPY server/discourse-nginx.conf /etc/nginx/conf.d/

# Link Persistant things
RUN ln -s /shared/uploads /apps/discourse/public/uploads
RUN ln -s /shared/cache /var/nginx/cache

# Add Artifacts
COPY assets/images/* /apps/discourse/public/images/

EXPOSE 80/tcp

WORKDIR /apps/discourse
CMD "/init"
