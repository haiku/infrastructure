# Pootle container

This is a custom container that builds Pootle with the workflow specifically
for Haiku.

It depends on:
 - PostgreSQL (we use postgres:9.6)
 - Redis (we use redis:4.0)

On the actual instance, it is good to use a persistent volume mounted at
/var/pootle.

The volume should contain the following:
 - A configuration file named `settings.conf` (this is created automatically
   the first time)
 - A configuration file named `sync-config.toml` (this file should follow the
   format of the sync-config.toml.example file that will be inst)
 - A `logs` directory
 - A `catalogs` directory with the pootle catalogs
 - A `repository` directory that contains the haiku repository
 - A `sync` directory that will contain the synchronization status

The pootle-entrypoint.sh contains two run commands:
 - `pootle` which starts an nginx frontend, a pootle server and a pootle rqworker
 - `synchronize` which collects the updated English catalogs, merges the
   existing translations, writes the merged files to disk and then commits
   them to the Haiku repository

The synchronization step requires that there is a haiku repository that is
configured for building. In the test setup the x86_gcc2 +x86 architectures are used.
