FROM nginx:alpine

COPY scripts/auto-reload /bin/auto-reload
COPY scripts/entrypoint /bin/entrypoint

RUN apk add --no-cache inotify-tools
RUN echo "include /etc/nginx/conf.d/backends/*.conf;" >> /etc/nginx/nginx.conf

CMD ["/bin/entrypoint"]
