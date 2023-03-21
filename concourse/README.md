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

### Setup

Create the initial required teams as an admin user...

```
fly -t haiku set-team -n continuous --github-team=haiku:infrastructure --non-interactive
fly -t haiku set-team -n nightly --github-team=haiku:infrastructure --non-interactive
fly -t haiku set-team -n r1beta1 --github-team=haiku:infrastructure --non-interactive
```

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

### secrets.yml

```secrets.yml``` contains secrets *used by* our concourse pipelines to update artifacts.

*Object Storage Access, Used to upload images / repos*
  * s3key - S3 Bucket Access Key
  * s3secret - S3 Bucket Secret Key

*Container Registry Access, Used to push 'toolchain' containers*
  * container-registry - Container registry / org (aka, ghcr.io/haiku)
  * container-registry-user - Container registry user
  * container-registry-password - Container registry password

## Deploying

./deploy.sh secrets.yml

## Teams

We use the "teams" feature of concourse to group related jobs together.

### Special Teams

* bootstrap - These pipelines run a bootstrap. These are generally hit or miss on functionality.
  * No outputs, mostly for debugging if our bootstap works for a specific architecture
* continuous - These pipelines run on every push to haiku.
  * Reports build failures to irc and elsewhere

### Release Teams

* nightly - These pipelines run nightly and push resulting artifacts to s3
  * Generate nightly images and repositories
  * aka everything on download.haiku-os.org and at https://eu.hpkg.haiku-os.org/haiku/master/(arch)/current
* r1beta3 - Release pipelines run on branch commits and push resulting artifacts to s3
  * Generate release images and repositories
    * Release images only generally used for release candidates until final release.
    * Repositories built through the whole life of a release to provide updates.
  * aka everything on download.haiku-os.org and at https://eu.hpkg.haiku-os.org/haiku/r1beta3/(arch)/current
