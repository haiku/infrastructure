FROM docker.io/python:3.15-alpine

LABEL org.opencontainers.image.source https://github.com/haiku/infrastructure
LABEL org.opencontainers.image.url https://github.com/haiku/infrastructure/tree/master/containers/services/trac/pypy
LABEL org.opencontainers.image.vendor Haiku, Inc.

# Set the working directory to /app
WORKDIR /app

RUN ls

# Copy the necessary files to the container
ADD requirements.txt /app

# Install the requirements
RUN apk add build-base libjpeg graphviz freetype libpq postgresql18-dev postgresql18-client curl git zlib

RUN python3 -m ensurepip && \
    python3 -mpip install -r requirements.txt

CMD /usr/local/bin/tracd -b 0.0.0.0 -p 80 -s /var/trac/dev.haiku-os.org

# Make port 80 available to the outside world
EXPOSE 80
