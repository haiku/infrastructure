# Traefik

[Traefik](https://traefik.io) is a dynamic reverse-proxy http/https server which was designed around the increasingly common task of routing virtual hosts and paths to multiple backend applications. In the container world it's called an *Ingress Controller*

## HTTPS / TLS

Traefik will automatically obtain SSL certificates for all exposed (sub)domains via ACME and Lets Encrypt. All certificates are obtained and renewed transparently (as long as the (sub)domain properly points to the host running Traefik for validation)

> In our original implementation, Traefik stored the ACME state data on disk in a persistant volume. We are slowly moving to etcd storage of ACME data (while moving to Docker swarm) so we can run more than one Traefik container for load balancing and reliability.

## Access Logs

Access logs are mounted to the host at /var/log/traefik as of this writing.

## Service Discovery

Our Traefik server is configured to leverage Docker as a data source. What this means is Traefik periodically polls Docker (via a socket mounted into the Traefik container) for what virtual hosts and paths to serve.

Traefik looks at labels assigned to containers for this information.

As an example, pootle (our translation application) has the following labels assigned:

```yaml
    labels:
      - "traefik.enable=true"
      - "traefik.basic.frontend.rule=Host:i18n.${DOMAIN};PathPrefixStrip:/pootle/"
      - "traefik.basic.port=80"
```

This instructs Traefik that:

  1. The container wants to be exposed via Traefik.
  2. The container should be exposed to the word on i18n.haiku-os.org at /pootle
  3. The container accepts traefik on port 80

## Static Paths

We have some static paths configured in our [traefik configuration](https://github.com/haiku/infrastructure/blob/master/data/traefik/traefik.toml) file which redirects some core things like haiku-os.org to www.haiku-os.org

