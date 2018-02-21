# Maui code lifecycle

The following list outlines the general process to add or change deployments on Maui.

## Code updated and tested

* Changes are made to the [infrastructure repository](https://github.com/haiku/infrastructure) repository
  * Any new containers have their relevant information added to docker-compose.yml
  * Any exposed services are added to ``data/router/*``
  * Changes tested locally (more information in [Local Testing](local-testing.md))
  * Changes submitted via Github Pull Request
* [Relevant automated builds](https://hub.docker.com/u/haiku/dashboard/) have triggered after PR acceptance.
  * New automated builds (for new containers) can be created by clicking [here](https://hub.docker.com/add/automated-build/github/form/haiku/infrastructure/?namespace=haiku)

## Code deployed

Container changes can be rolled out individually by performing the pull/down/up on an individual container.
For completeless however, we will be re-deploying all services in this example.

* Change to infrastructure directory
  * ``cd ~/infrastructure``
* Updated git repository is checked out on maui
  * ``git stash; git pull; git stash pop;``
* Updated containers are pulled
  * ``docker-compose pull``
* Updated containers deployed
  * ``docker-compose down; docker-compose up -d``

> TIP: Docker containers can be destroyed without dataloss when designed properly, everything unique should be contained within docker volumes which are backed-up.
