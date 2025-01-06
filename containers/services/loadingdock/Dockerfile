FROM docker.io/alpine:3.4

MAINTAINER Haiku, Inc.
LABEL org.opencontainers.image.source https://github.com/haiku/infrastructure
LABEL org.opencontainers.image.url https://github.com/haiku/infrastructure/tree/master/containers/services/loadingdock
LABEL org.opencontainers.image.vendor Haiku, Inc.

RUN apk update && apk upgrade &&  apk --update --no-cache add openssh bash curl jq \
	&& adduser -D -H -s /bin/bash -G users submit \
	&& passwd -u submit \
	&& mkdir /etc/authorized_keys

ADD entry.sh /entry.sh
RUN chmod 755 /entry.sh && mkdir /sftp

ADD sshd_config /etc/ssh/sshd_config

EXPOSE 22

ENTRYPOINT ["/entry.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
