FROM alpine
LABEL maintainer "Haiku, Inc <haiku.inc@gmail.com>"

RUN apk add --no-cache openssh rsync bash \
  && sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config \
  && sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_key/HostKey \/etc\/ssh\/ssh_host_key/g' /etc/ssh/sshd_config \
  && sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config \
  && sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_dsa_key/HostKey \/etc\/ssh\/ssh_host_dsa_key/g' /etc/ssh/sshd_config \
  && sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config \
  && sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config \
  && sed -i '/PasswordAuthentication /c\PasswordAuthentication no' /etc/ssh/sshd_config \
  && sed -i '/PermitEmptyPasswords /c\PermitEmptyPasswords no' /etc/ssh/sshd_config \
  && ssh-keygen -A \
  && ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_key

RUN sed -ie 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config \
    && sed -ie 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config \
    && sed -ie 's/#PermitRootLogin prohibit-password/PermitRootLogin without-password/g' /etc/ssh/sshd_config

RUN passwd -u root

RUN mkdir /root/.keys
ADD keys/* /root/.keys/

COPY entrypoint.sh /
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
