FROM alpine
LABEL maintainer "Haiku, Inc <haiku.inc@gmail.com>"

RUN apk add --no-cache openssh rsync \
  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ without-password/ /etc/ssh/sshd_config

RUN mkdir /root/.keys
ADD keys/* /root/.keys/

COPY entrypoint.sh /
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
