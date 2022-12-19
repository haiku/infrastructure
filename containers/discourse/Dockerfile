#
# A sane discourse container without the "meta-build" and "launcher"
#
FROM docker.io/ruby:3.0-bullseye

MAINTAINER Haiku, Inc. <contact@haiku-os.org>

ARG VERSION 2.8.0
ENV DISCOURSE_VERSION $VERSION

# Add the postgresql software repository (not available in main Debian yet)
# See: https://www.postgresql.org/download/linux/debian/

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && apt-get install -y git bash build-essential postgresql-client-14 python3 python3-pip cron nginx pngquant optipng gifsicle jpegoptim jhead brotli uglifyjs npm && pip3 install supervisor
RUN rm /etc/nginx/sites-enabled/default && mkdir -p /var/nginx && chown www-data:www-data /var/nginx && echo "daemon off;" >> /etc/nginx/nginx.conf

# Install Discourse
ADD https://github.com/discourse/discourse/archive/v$DISCOURSE_VERSION.tar.gz /release.tar.gz
RUN mkdir -p /apps && cd /apps && tar xvf /release.tar.gz && rm /release.tar.gz && mv /apps/discourse-$DISCOURSE_VERSION /apps/discourse
RUN gem install bundler:2.3.4 && npm install -g terser
RUN cd /apps/discourse && bundle install

COPY supervisord.conf /etc/supervisord.conf
COPY init /init
RUN chmod 755 /init
COPY server/discourse-nginx.conf /etc/nginx/conf.d/

# Link Persistant things
RUN ln -s /shared/uploads /apps/discourse/public/uploads && \
	ln -s /shared/log/rails /apps/discourse/logs && \
	ln -s /shared/backups /apps/discourse/public/backups

# Add Artifacts
COPY assets/images/* /apps/discourse/public/images/

EXPOSE 80/tcp

WORKDIR /apps/discourse

CMD "/init"

HEALTHCHECK --start-period=5m CMD curl --fail http://`hostname`:80/ || exit 1
