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

## Terms

* Concourse - A continious integration system which builds code based on YAML pipeline defines
  * web - The main concourse web server / build orchestration system.
    * ATC, Air Traffic Control - Web UI, API, Scheduler
    * TSA - A managed SSH reverse proxy. All worker communication occurs here.
  * worker - A host which runs containers. Accessed over SSH.
    * Beacon - Manages the worker processes
    * Baggageclaim - An API to manage container volumes on the local host.
    * Garden - An API to manage containers running on the local host.
      * Concourse planning on replacing with containerd
* Object Storage - S3 repositories where we upload build artifacts for public consumption
* General Worker - A container we build which has "the basics to build Haiku and upload artifacts"
* Toolchain Container - A docker container we push to docker hub with *all* of our toolchains pre-compiled.
  * Based on ```General Worker``` plus our compiled toolchains.
  * *latest* is the latest toolchain container
  * *(hash)* is the git hash of the buildtools repo used to generate the toolchains within.

## Secrets

### secrets.fly

```secrets.fly``` contains information to automatically log into our concourse server.

### secrets.yml

```secrets.yml``` contains secrets *used by* our concourse pipelines to update artifacts.

*Object Storage Access, Used to upload images / repos*
  * s3key - S3 Bucket Access Key
  * s3secret - S3 Bucket Secret Key
  * s3endpoint - S3 Server

*Docker Hub Access, Used to push 'toolchain' containers*
  * docker-hub-user - Docker Hub User
  * docker-hub-password - Docker Hub Password

## Deploying

./deploy.sh secrets.fly secrets.yml
