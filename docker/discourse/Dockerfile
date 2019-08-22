FROM ruby:latest

ENV DISCOURSE_VERSION=2.3.2

RUN apt-get update && apt-get install -y git bash build-essential postgresql-client python python-pip cron && pip install supervisor
ADD https://github.com/discourse/discourse/archive/v$DISCOURSE_VERSION.tar.gz /release.tar.gz
RUN mkdir -p /apps && cd /apps && tar xvf /release.tar.gz && rm /release.tar.gz && mv /apps/discourse-$DISCOURSE_VERSION /apps/discourse
RUN cd /apps/discourse && bundle install
COPY supervisord.conf /etc/supervisord.conf
COPY init /init
RUN chmod 755 /init

CMD "/init"
