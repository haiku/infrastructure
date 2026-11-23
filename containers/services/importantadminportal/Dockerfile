FROM rust:1.98-alpine AS build

RUN apk add --no-cache musl-dev
WORKDIR /src

COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo build --release --locked

FROM alpine:3.22

RUN addgroup -S portal \
    && adduser -S -G portal portal \
    && mkdir -p /data \
    && chown portal:portal /data

COPY --from=build /src/target/release/importantadminportal /usr/local/bin/importantadminportal

USER portal
ENV BIND_ADDR=0.0.0.0:8080 \
    DATA_DIR=/data \
    RUST_LOG=info

EXPOSE 8080
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
    CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1

ENTRYPOINT ["/usr/local/bin/importantadminportal"]
