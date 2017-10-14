## nginx-router

This container is the only externally-facing container and handles
all requests for all of the Haiku infrastructure.

nginx service within container should auto-reload when configuration
files are modified.

### Persistant volume

A persistant volume is required at /etc/nginx/conf.d

  * /etc/nginx/conf.d
    * One .conf file per http/https service exposure
  * /etc/nginx/conf.d/backends
    * One .conf file per non-http/https service exposure

### Load balancing

If we grow, we might want to consider running a few of these sharing
the same config files and doing some basic global traffic management
via multiple DNS records.
