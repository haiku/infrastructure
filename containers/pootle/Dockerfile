FROM debian:buster-slim

# Set the working directory to /app
WORKDIR /app

# Copy the necessary files to the container
ADD requirements.txt /app
ADD pootle-entrypoint.sh /app
ADD synchronize-template.html /app
ADD synchronize-email-template.txt /app
ADD sync-config.toml.example /app/sync-config.toml.example
ADD scripts/finish_output_catalogs.py /app
ADD scripts/fingerprint.py /app
ADD scripts/import_templates_from_remote.py /app
ADD scripts/synchronize.py /app
RUN chmod +x /app/pootle-entrypoint.sh

# Add software (to be used to extract new catalogs)
RUN apt-get update && \
    apt-get -y install  git \
                        build-essential \
                        postgresql-server-dev-11 \
                        python-pip \
                        libxml2-dev \
                        libxslt1-dev \
                        zlib1g-dev \ 
                        nano \
                        cron \
                        nginx \
                        supervisor

# Install Pootle
RUN pip install -r requirements.txt
ENV POOTLE_SETTINGS /var/pootle/settings.conf
ENV SYNC_CONFIG /var/pootle/sync-config.toml

# Set up Supervisor.
RUN sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf
ADD supervisor/pootle.conf supervisor/nginx.conf supervisor/cron.conf /etc/supervisor/conf.d/

# Set up nginx
ADD nginx/default /etc/nginx/sites-available/

# Set up cron
ADD scripts/synchronize-cron /etc/cron.d/synchronize-cron
RUN chmod 0644 /etc/cron.d/synchronize-cron
RUN crontab /etc/cron.d/synchronize-cron

ENTRYPOINT ["/app/pootle-entrypoint.sh"]

CMD ["pootle"]

# Make port 80 available to the outside world
EXPOSE 80
