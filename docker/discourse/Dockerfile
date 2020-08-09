#
# A sane discourse container without the "meta-build" and "launcher"
#
FROM ruby:latest

MAINTAINER Haiku, Inc. <contact@haiku-os.org>

ENV DISCOURSE_VERSION=2.5.0

RUN apt-get update && apt-get install -y git bash build-essential postgresql-client python3 python3-pip cron nginx pngquant optipng gifsicle jpegoptim jhead brotli uglifyjs npm && pip3 install supervisor
RUN npm install -g svgo
RUN rm /etc/nginx/sites-enabled/default && mkdir -p /var/nginx && chown www-data:www-data /var/nginx && echo "daemon off;" >> /etc/nginx/nginx.conf

# Install Discourse
ADD https://github.com/discourse/discourse/archive/v$DISCOURSE_VERSION.tar.gz /release.tar.gz
RUN mkdir -p /apps && cd /apps && tar xvf /release.tar.gz && rm /release.tar.gz && mv /apps/discourse-$DISCOURSE_VERSION /apps/discourse
RUN cd /apps/discourse && bundle install

COPY supervisord.conf /etc/supervisord.conf
COPY init /init
RUN chmod 755 /init
COPY server/discourse-nginx.conf /etc/nginx/conf.d/

# Link Persistant things
RUN ln -s /shared/uploads /apps/discourse/public/uploads && \
	ln -s /shared/log/rails /apps/discourse/logs

# Add Artifacts
COPY assets/images/* /apps/discourse/public/images/

EXPOSE 80/tcp

WORKDIR /apps/discourse

CMD "/init"

HEALTHCHECK --start-period=5m CMD curl --fail http://`hostname`:80/ || exit 1
