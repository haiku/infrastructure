FROM nginx:alpine

COPY auto-reload.sh /bin/auto-reload
COPY entrypoint.sh /bin/entrypoint

RUN apk add --no-cache inotify-tools

CMD ["/bin/entrypoint"]
