FROM docker.io/pypy:3.10-slim

LABEL org.opencontainers.image.source https://github.com/haiku/infrastructure
LABEL org.opencontainers.image.url https://github.com/haiku/infrastructure/tree/master/containers/trac/pypy
LABEL org.opencontainers.image.vendor Haiku, Inc.

# Set the working directory to /app
WORKDIR /app

RUN ls

# Copy the necessary files to the container
ADD requirements.txt /app

# Install the requirements
RUN apt update && \
    apt install -y build-essential gcc libjpeg-dev libfreetype-dev libpq-dev curl git zlib1g-dev

RUN pypy -m ensurepip && \
    pypy -mpip install -r requirements.txt

CMD /opt/pypy/bin/tracd -b 0.0.0.0 -p 80 -s /var/trac/dev.haiku-os.org

# Make port 80 available to the outside world
EXPOSE 80
