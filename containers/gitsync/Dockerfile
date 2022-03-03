FROM docker.io/alpine:3.15

ENV GIT_ORG haiku
ENV GIT_SERVER github.com
ENV GIT_PREFIX /data/git
ENV GIT_REPOS "haiku.git buildtools.git"
ENV SSH_IDENTITY /run/secrets/ssh/private

RUN apk add --update-cache git openssh-client
ADD gitsync /usr/local/bin/gitsync
RUN chmod 755 /usr/local/bin/gitsync

ENTRYPOINT ["/usr/local/bin/gitsync"]
