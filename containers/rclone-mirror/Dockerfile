FROM docker.io/alpine:3.15
ADD entry.sh /entry.sh
RUN apk --update --no-cache add bash rclone && chmod 755 /entry.sh
CMD /entry.sh
