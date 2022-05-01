FROM docker.io/nginx:1.21-alpine
ADD entry /entry
RUN chmod 755 /entry
ENTRYPOINT ["/entry"]
