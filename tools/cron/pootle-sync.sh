#!/bin/sh
POOTLE_CONTAINER_ID=$(docker ps --filter "name=infrastructure_pootle_1" -q)
POSTGRES_CONTAINER_ID=$(docker ps --filter "name=infrastructure_postgres_1" -q)

# Make a backup of the database
docker exec POOTLE_CONTAINER_ID rm -r /var/pootle/db-backup.sql
docker exec $POSTGRES_CONTAINER_ID pg_dump -U baron pootle_production | docker exec -i $POOTLE_CONTAINER_ID dd of=/var/trac/db-backup.sql

# Run the sync script
docker exec $POOTLE_CONTAINER_ID /app/pootle-entrypoint.sh synchronize
