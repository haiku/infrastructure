# set up a database for discourse to use
db_name=discourse
db_user=discourse
cat <<EOF | docker exec -i infrastructure_postgres_1 sh
su postgres -c "createdb $db_name" || true
su postgres -c "psql $db_name -c \"create user $db_user;\"" || true
su postgres -c "psql $db_name -c \"grant all privileges on database $db_name to $db_user;\"" || true
su postgres -c "psql $db_name -c \"alter schema public owner to $db_user;\""
su postgres -c "psql template1 -c \"create extension if not exists hstore;\""
su postgres -c "psql template1 -c \"create extension if not exists pg_trgm;\""
su postgres -c "psql $db_name -c \"create extension if not exists hstore;\""
su postgres -c "psql $db_name -c \"create extension if not exists pg_trgm;\""
EOF

# container used to build discourse
docker build -t local/discuss_builder .

# do the build inside our container
docker rm --force discuss
docker rmi --force local_discourse/discuss
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock:z -w /var/discourse/docker \
  local/discuss_builder ./launcher bootstrap discuss \
  --docker-args "--network infrastructure_default -v $(pwd)/images:/images"
# produces tagged image: local_discourse/discuss
docker image tag local_discourse/discuss haiku/discuss

# clean up the builder
docker rmi --force local/discuss_builder
