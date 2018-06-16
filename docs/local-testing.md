Local Testing
======================================

The Haiku infrastructure can be deployed to a local system
for testing purposes.

Requirements
------------

1. docker and docker-compose installed
2. this repository
3. a persistant volume with the unique maui data
4. Add the following to your /etc/hosts:
```
127.0.0.1 review-local.haiku-os.org cgit-local.haiku-os.org git-local.haiku-os.org haiku-os.org api-local.haiku-os.org userguide-local.haiku-os.org ports-mirror-local.haiku-os.org
```

Your test environment
----------------------------------

From the root infrastructure directory...

1. Disable ACME in data/traefik/traefik.toml
2. docker-compose pull
3. DOMAIN_POST="-local" docker-compose up -d


Helpful hints
----------------------------------

The persistant data needs to be imported to the infrastructure_gerrit_data
named volume.  To see where this volume exists on your system, you can run:

```docker inspect infrastructure_gerrit_data```


If Chrome HSTS kicks in, just type ```badidea``` anywhere into the web page.
