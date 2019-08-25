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

* Admin summary page shows an error... not sure yet
* Connecting a tty to the discourse container will result in
  random redis connection errors and the site randomly failing
  to work. See the following:
  * https://meta.discourse.org/t/discourse-web-interface-becomes-unresponsive-a-few-minutes-after-starting/76643/14
  * https://github.com/moby/moby/issues/35865
* Logs are in the wrong spot and rotation needs setup
