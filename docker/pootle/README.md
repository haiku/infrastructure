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

The pootle-entrypoint.sh contains on specialized run command:
 - `pootle` which starts an nginx frontend, cron for the weekly sync, a pootle server and a pootle rqworker

## Configuring the Haiku Repository
In order to make sure that the catkeys for WebPositive are build, you need to
manually enable the `webkit` feature. Within the `/var/pootle/repository` dir,
add a `generated/UserBuildConfig` file with the line `EnableBuildFeatures webkit ;`.

## Synchronization

Synchronization is a list of actions that need to be taken to roughly:
 - Write the latest translations to the disk (using pootle's `sync_stores` command)
 - Extract the latest catalog templates in English from the source (`jam -q catkeys`)
 - Update the translated files to include new strings, and drop old ones (`import_templates_from_repository.py`)
 - Update the state of the database to represent the merged files (pootle's `update_stores`)
 - Post process the translated files, like remove the empty (untranslated) lines (`finish_output_catalogs.py`)
 - Commit them to the Haiku repository, and push them upstream.

These steps are executed by the `/app/synchronize.py` script. The steps are configured in the 
`/var/pootle/sync-config.toml` file. Most notably, the list of output languages can be configured there.

The image is set up in such a way that every Saturday at 08:00 AM, the script will run. The script will output all the
console output online (`https://i18n.haiku-os.org/pootle/sync-status.html`), as well as send an email. 

## Recalculating loop

Sometimes Pootle gets stuck on recalculating the latest stats. In that case, it is easiest to run `pootle shell` and
enter the following python lines:

```python
from django_rq.queues import get_connection
POOTLE_DIRTY_TREEITEMS = 'pootle:dirty:treeitems'
c = get_connection()
keys = c.zrangebyscore(POOTLE_DIRTY_TREEITEMS, 1, 1000000)
updates = {k: 0.0 for k in keys}
c.zadd(POOTLE_DIRTY_TREEITEMS, **updates)
```

After that, you may want to run `pootle refresh_stats`.
(Source: https://github.com/translate/pootle/issues/3409#issuecomment-160128127)
