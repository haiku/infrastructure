FROM python:2.7

# Set the working directory to /app
WORKDIR /app

# Copy the necessary files to the container
ADD requirements.txt /app
ADD pootle-entrypoint.sh /app
ADD scripts/finish_output_catalogs.py /app
ADD scripts/fingerprint.py /app
ADD scripts/import_templates_from_repository.py /app
RUN chmod +x /app/pootle-entrypoint.sh

# Build jam (to be used to extract new catalogs)
RUN git clone https://git.haiku-os.org/buildtools
WORKDIR /app/buildtools/jam
RUN make
RUN ./jam0 install
WORKDIR /app
RUN rm -rf buildtools

# Install the requirements to get the generated catkeys
RUN apt-get update && \
    apt-get install nasm gawk

RUN pip install -r requirements.txt

ENV POOTLE_SETTINGS /var/pootle/settings.conf

ENTRYPOINT ["/app/pootle-entrypoint.sh"]

CMD ["pootle"]

# Make port 80 available to the outside world
EXPOSE 80
