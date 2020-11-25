FROM alpine:latest
MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

RUN apk add --update python python-dev py-pip build-base libffi-dev openssl-dev sqlite
RUN pip install u2fval
RUN mkdir -p /etc/yubico/u2fval
ADD u2fval.conf /etc/yubico/u2fval/u2fval.conf

VOLUME ["/u2fval"]
EXPOSE 8080
ENTRYPOINT ["u2fval", "run", "-i", "0.0.0.0"]
