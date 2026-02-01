# Discourse (less dumb version)

This is discourse packaged like a normal sane application.

## Bootstrap

Here are the steps to setup an initial database on new installs:
```
docker exec -it (container-id) /bin/bash -l
cd /apps/discourse
bundle exec rake db:create
```

## Discourse Strategy
Discourse has a new [Release Strategy](https://meta.discourse.org/t/rfc-a-new-versioning-strategy-for-discourse/383536) since 2026 with a new [Release Info Page](https://releases.discourse.org/).

## Known Issues

* Logs are in the wrong spot and rotation needs setup
