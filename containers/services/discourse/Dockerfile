#
# A sane discourse container without the "meta-build" and "launcher"
#
FROM docker.io/ruby:3.3-bookworm

MAINTAINER Haiku, Inc. <contact@haiku-os.org>
LABEL org.opencontainers.image.source https://github.com/haiku/infrastructure
LABEL org.opencontainers.image.url https://github.com/haiku/infrastructure/tree/master/containers/services/discourse
LABEL org.opencontainers.image.vendor Haiku, Inc.

ARG VERSION=3.4.4
ENV DISCOURSE_VERSION $VERSION

# Add the postgresql software repository (not available in main Debian yet)
# See: https://www.postgresql.org/download/linux/debian/

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Add the Node software repositories
# See https://github.com/discourse/discourse_docker/blob/225c3d03896c0573363183118ce58622f039083b/image/base/slim.Dockerfile 32-35
RUN wget --quiet -O - https://deb.nodesource.com/setup_22.x | bash -

RUN apt-get update \
    && apt-get install -y git bash build-essential postgresql-client-15 postgresql-15-pgvector \
		python3 python3-pip cron nginx pngquant optipng gifsicle jpegoptim jhead brotli nodejs \
		ripgrep supervisor imagemagick
RUN rm /etc/nginx/sites-enabled/default && mkdir -p /var/nginx && chown www-data:www-data /var/nginx && echo "daemon off;" >> /etc/nginx/nginx.conf

# Install a rust compiler and install oxipng
# See: https://github.com/discourse/discourse_docker/blob/225c3d03896c0573363183118ce58622f039083b/image/base/install-rust
#      https://github.com/discourse/discourse_docker/blob/225c3d03896c0573363183118ce58622f039083b/image/base/install-oxipng

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal \
    && . $HOME/.cargo/env \
	&&  cargo install oxipng \
	&& mv $HOME/.cargo/bin/oxipng /usr/local/bin/ \
	&& rustup self uninstall -y

# Imagemagick: the discourse/lib/letter_avatar.rb expects there to be a `magick` command
# Link the installed imagemagick convert
RUN ln -s /usr/bin/convert-im6.q16 /usr/bin/magick

# Install Discourse
# See: https://github.com/discourse/discourse_docker/blob/225c3d03896c0573363183118ce58622f039083b/image/base/release.Dockerfile
ADD https://github.com/discourse/discourse/archive/v$DISCOURSE_VERSION.tar.gz /release.tar.gz
RUN mkdir -p /apps && cd /apps && tar xf /release.tar.gz && rm /release.tar.gz && mv /apps/discourse-$DISCOURSE_VERSION /apps/discourse
RUN npm install -g ember-cli terser uglify-js pnpm@9
RUN cd /apps/discourse \
	&& bundle config --local deployment true \
	&& bundle config --local path ./vendor/bundle \
	&& bundle config --local without test development \
    && bundle install \
	&& pnpm install --frozen-lockfile \
	&& find /apps/discourse/vendor/bundle -name tmp -type d -exec rm -rf {} +

# Set up Supervisor and nginx
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

