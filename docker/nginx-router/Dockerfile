FROM nginx:alpine

COPY scripts/auto-reload /bin/auto-reload
COPY scripts/entrypoint /bin/entrypoint

RUN apk add --no-cache inotify-tools
RUN sed -i '/worker_processes/c\worker_processes 8;' /etc/nginx/nginx.conf
RUN echo "include /etc/nginx/conf.d/backends/*.conf;" >> /etc/nginx/nginx.conf

CMD ["/bin/entrypoint"]
