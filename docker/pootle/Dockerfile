FROM debian:stretch-slim

# Set the working directory to /app
WORKDIR /app

# Copy the necessary files to the container
ADD requirements.txt /app
ADD pootle-entrypoint.sh /app
ADD synchronize-template.html /app
ADD synchronize-email-template.txt /app
ADD scripts/finish_output_catalogs.py /app
ADD scripts/fingerprint.py /app
ADD scripts/import_templates_from_repository.py /app
ADD scripts/synchronize.py /app
RUN chmod +x /app/pootle-entrypoint.sh

# Add software (to be used to extract new catalogs)
RUN apt-get update && \
    apt-get -y install  git \
                        nasm \
                        autoconf \
                        automake \
                        texinfo \
                        flex \
                        bison \
                        gawk \
                        build-essential \
                        unzip \
                        wget \
                        zip \
                        less \
                        zlib1g-dev \
                        libcurl4-openssl-dev \
                        genisoimage \
                        libtool \
                        mtools \
                        clang \
                        postgresql-server-dev-9.6 \
                        python-pip \
                        libxml2-dev \
                        libxslt1-dev \
                        nginx \
                        supervisor

# Create a working jam
RUN git clone --depth 1 https://review.haiku-os.org/buildtools
WORKDIR /app/buildtools/jam
RUN make
RUN ./jam0 install
WORKDIR /app
RUN rm -rf buildtools

# Install Pootle
RUN pip install -r requirements.txt
ENV POOTLE_SETTINGS /var/pootle/settings.conf

# Set up Supervisor.
RUN sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf
ADD supervisor/pootle.conf supervisor/nginx.conf /etc/supervisor/conf.d/

# Set up nginx
ADD nginx/default /etc/nginx/sites-available/

ENTRYPOINT ["/app/pootle-entrypoint.sh"]

CMD ["pootle"]

# Make port 80 available to the outside world
EXPOSE 80
