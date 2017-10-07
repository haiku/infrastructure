FROM nginx:alpine

COPY scripts/auto-reload /bin/auto-reload
COPY scripts/entrypoint /bin/entrypoint

RUN apk add --no-cache inotify-tools

CMD ["/bin/entrypoint"]
