FROM docker.io/pypy:2.7-slim

# Set the working directory to /app
WORKDIR /app

RUN ls

# Copy the necessary files to the container
ADD requirements.txt /app

# Install the requirements
RUN apt update && \
    apt install -y build-essential gcc libpq-dev curl git

RUN pypy -m ensurepip && \
    pypy -mpip install -r requirements.txt

CMD /opt/pypy/bin/tracd -b 0.0.0.0 -p 80 -s /var/trac/dev.haiku-os.org

# Make port 80 available to the outside world
EXPOSE 80

HEALTHCHECK CMD curl --fail http://`hostname`:80/ || exit 1
