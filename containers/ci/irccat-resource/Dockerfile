FROM alpine
RUN apk --no-cache add bash ruby ruby-dev ruby-rdoc ca-certificates git build-base && gem install json && gem install pp
RUN mkdir -p /opt/resource
ADD bin/* /opt/resource/
RUN chmod 755 /opt/resource/*
