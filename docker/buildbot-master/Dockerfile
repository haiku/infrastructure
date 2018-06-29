FROM buildbot/buildbot-master:v1.2.0

# needed for the docker latent worker plugin
RUN pip --no-cache-dir install 'docker-py'

COPY ./start_buildbot.sh /usr/src/buildbot/docker/start_buildbot.sh

RUN chmod a+x /usr/src/buildbot/docker/start_buildbot.sh
