# Concourse 

https://concourse-ci.org

Concourse is a yml based build system which lets you manage
builds via yml manifests.  Builds run within containers, and concourse
provides a cli-based administration tool.

## Quick Start

Run the following:
```
$ wget https://concourse-ci.org/docker-compose.yml
$ docker-compose up -d
Creating docs_concourse-db_1 ...
Creating docs_concourse-db_1 ... done
Creating docs_concourse_1 ...
Creating docs_concourse_1 ... done
```

Concourse is now running on localhost:8080. The username / password is test/test.

Install the fly CLI by downloading it from the web ui and placing it at /usr/local/bin/fly
