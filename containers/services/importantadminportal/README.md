# Important Admin Portal

A tiny Rust honeypot that pretends to be an internal administration portal.
It exists to absorb and record traffic from scrapers, exploit scanners, and
other bad actors.

## What it does

* Presents a believable admin portal (login, dashboard, users, audit log,
  backups, integrations) with fake internal hostnames and credentials.
* Serves decoy files commonly probed for by scanners: `.env`, `wp-config.php`,
  SQL dumps, `.git/config`, AWS credentials, SSH keys, phpMyAdmin/Adminer
  login pages, Tomcat/WebLogic consoles, `terraform.tfstate`, and more.
* Returns a plausible file for any unknown file-like path (for example
  `/uploads/export.sql`) instead of a 404.
* Ignores requests whose source address is not publicly routable: loopback,
  RFC 1918, link-local, CGNAT, multicast, documentation and other reserved
  ranges are never logged or recorded.
* Logs hostile requests to stdout with source IP, method, URI, user agent and
  referer.
* Appends every hostile source IP to `ips.txt`, one address per line.
* Periodically rewrites `ips.txt` with one line per unique address (first-seen
  order preserved).
* Serves the current report at `/report.txt` to any client. Reading the
  report does not add the client to the report.

Requests for `/report.txt` and `/healthz` are never logged or recorded, so
operators and monitoring can read them safely.

## Endpoints

| Path | Description |
| --- | --- |
| `/` | Portal login page |
| `/admin`, `/admin/users`, `/admin/settings`, ... | Fake administration pages |
| `/admin/login` | Accepts a form post and always rejects it (401) |
| `/report.txt` | Current IP report (`text/plain`, not tracked) |
| `/healthz` | Health check (not tracked) |
| `/robots.txt` | Plausible robots file |
| everything else | Decoy file or 404 |

## Configuration

All configuration is via environment variables.

| Variable | Default | Description |
| --- | --- | --- |
| `BIND_ADDR` | `0.0.0.0:8080` | Listen address |
| `DATA_DIR` | `./data` | Directory for the IP log |
| `IP_LOG_FILE` | `$DATA_DIR/ips.txt` | Explicit IP log path |
| `COMPACT_INTERVAL_SECS` | `600` | Deduplication interval (minimum 10) |
| `TRUST_PROXY_HEADERS` | `true` | Use `X-Forwarded-For`/`X-Real-IP` when the direct peer is internal |
| `DECOY_FALLBACK` | `true` | Generate a decoy for unknown file-like paths |
| `RUST_LOG` | `info` | Log filter (`tracing` syntax) |

Proxy headers are only trusted when the TCP peer is itself a non-public
address. A client connecting directly from the internet therefore cannot
spoof its address, while requests arriving through an internal ingress are
resolved to the original client.

## Running locally

```sh
cargo run
# or
make build && make run
```

Then:

```sh
curl http://127.0.0.1:8080/            # portal login
curl http://127.0.0.1:8080/.env        # decoy
curl http://127.0.0.1:8080/report.txt  # recorded hosts
```

The quickest way to exercise recording locally is to send a forwarded header
from an internal peer:

```sh
curl -H 'X-Forwarded-For: 8.8.8.8' http://127.0.0.1:8080/backup.sql
```

The address is only used as the recorded client address; no traffic is sent
to it.

## Deployment notes

* Run **one replica** and mount a persistent volume at `/data`. The IP log is
  local to the container; multiple replicas would each keep their own report.
* The ingress must preserve the client address in `X-Forwarded-For` (Traefik
  does this by default).
* `/report.txt` is intentionally public, and requesting it never adds the
  client to the report. It only contains source addresses of clients that
  probed the honeypot, which may include benign crawlers.
* The credentials and files served by the portal are randomly generated fakes.
  They must never be used for anything real.

Example container build:

```sh
make build
make push
```

## Layout

```
src/main.rs     HTTP server, tracking middleware, periodic compaction
src/config.rs   environment configuration
src/ip.rs       client address resolution and public/private classification
src/store.rs    append-only IP log and unique compaction
src/decoys.rs   generated decoy files
src/portal.rs   fake admin portal HTML
```
