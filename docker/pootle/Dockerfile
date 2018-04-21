FROM alpine:3.7

# Set the working directory to /app
WORKDIR /app

# Copy the necessary files to the container
ADD requirements.txt /app
ADD pootle-entrypoint.sh /app
ADD scripts/finish_output_catalogs.py /app
ADD scripts/fingerprint.py /app
ADD scripts/import_templates_from_repository.py /app
RUN chmod +x /app/pootle-entrypoint.sh

# Add software (to be used to extract new catalogs)
RUN apk update &&          \
    apk add build-base     \
        git                \
        bison              \
        bsd-compat-headers \
        curl-dev           \
        flex               \
        gawk               \
        nasm               \
        tar                \
        texinfo            \
        wget               \
        libxml2-dev        \
        libxslt-dev        \
        python2            \
        python2-dev        \
        py2-pip            \
        postgresql-dev     \
        nginx              \
        supervisor

# Create a working jam
RUN git clone https://git.haiku-os.org/buildtools
WORKDIR /app/buildtools/jam
RUN make
RUN ./jam0 install
WORKDIR /app
RUN rm -rf buildtools

# Install Pootle
RUN pip install -r requirements.txt
ENV POOTLE_SETTINGS /var/pootle/settings.conf

# Set up Supervisor.
RUN sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisord.conf && \
    mkdir /etc/supervisor.d
ADD supervisor/pootle.ini supervisor/nginx.ini /etc/supervisor.d/

# Set up nginx
RUN mkdir /run/nginx
ADD nginx/default.conf /etc/nginx/conf.d/

ENTRYPOINT ["/app/pootle-entrypoint.sh"]

CMD ["pootle"]

# Make port 80 available to the outside world
EXPOSE 80
