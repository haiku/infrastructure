FROM golang
RUN go get github.com/prometheus/node_exporter
RUN GOOS=linux CGO_ENABLED=0 go install github.com/prometheus/node_exporter

FROM        quay.io/prometheus/busybox:glibc
COPY --from=0 /go/bin/node_exporter /bin/node_exporter

EXPOSE      9100
USER        nobody
ENTRYPOINT  [ "/bin/node_exporter" ]
