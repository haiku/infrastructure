# Discourse (less dumb version)

This is discourse packaged like a normal sane application.

## Bootstrap

Here are the steps to setup an initial database on new installs:
```
docker exec -it (container-id) /bin/bash -l
cd /apps/discourse
bundle exec rake db:create
```

## Known Issues

* Logs are in the wrong spot and rotation needs setup
