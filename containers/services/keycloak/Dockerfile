# Stage 1
FROM quay.io/keycloak/keycloak:26.1.5 as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak

COPY themes/ /opt/keycloak/themes/
COPY realms/ /opt/keycloak/data/import/

# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:sso.haiku-os.org" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

# Stage 2
FROM quay.io/keycloak/keycloak:26.1.5

COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
