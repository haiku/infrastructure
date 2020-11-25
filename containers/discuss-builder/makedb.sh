#!/bin/bash
# set up a database for discourse to use
db_name=discourse
db_user=discourse
cat <<EOF | docker exec -i infrastructure_postgres_1 sh
su postgres -c "createdb -U baron $db_name" || true
su postgres -c "psql -U baron $db_name -c \"create user $db_user;\"" || true
su postgres -c "psql -U baron $db_name -c \"grant all privileges on database $db_name to $db_user;\"" || true
su postgres -c "psql -U baron $db_name -c \"alter schema public owner to $db_user;\""
su postgres -c "psql -U baron template1 -c \"create extension if not exists hstore;\""
su postgres -c "psql -U baron template1 -c \"create extension if not exists pg_trgm;\""
su postgres -c "psql -U baron $db_name -c \"create extension if not exists hstore;\""
su postgres -c "psql -U baron $db_name -c \"create extension if not exists pg_trgm;\""
EOF
