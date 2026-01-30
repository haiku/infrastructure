FROM docker.io/alpine:3.4

ADD forklift.sh /forklift.sh
RUN apk update && apk upgrade &&  apk --update --no-cache add bash \
    && chmod 755 /forklift.sh

CMD ["/forklift.sh"]
