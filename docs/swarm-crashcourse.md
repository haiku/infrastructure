# Docker Swarm

Docker swarm is a system to manage "services" within docker.

The concept of a service is a layer above docker containers.
Think of a service as a "desired state" of a container.

A stack is a grouping of services and networks.

## Stacks

We break our infrastructure out into several stacks:

**Critical**

> These must be up first to deploy the rest

  * ingress - Traefik routing to all of our containers.
    Public facing entrance to most of our http-based applications. The ingress stack
    creates one ingress network per stack which the stacks attach to.
  * support - A grouping of support applications for the rest of our infrastructure.
    These support applications are not generally not exposed via the ingress and are
    for internal use. (postgres, redis, smtp relay, etc)

**Everything else**

  * sysadmin - Management and monitoring applications. Metric collection and admin tools.
  * cdn - File management applications.  minio s3 server, revere proxies and rewrite servers
    for file and repo management.
  * ci - Continuous integration tools like buildbot, haikuports buildmaster, concourse.
  * dev - Gerrit, Git, Trac, userguide, pootle, and any other "development" applications.
  * community - Community support and engagement tools like discourse

All of the stacks can be deployed via ```make deploy```, or you can deploy a single stack via:
```
DOMAIN=haiku-os.org docker stack deploy -c mystack.yaml mystack
```

> Be sure the stack name matches the filename for consistency.

**To undeploy a stack:**
```
docker stack rm (name)
```
> Removing a service will not remove the persistent data volumes attached to it.

The stack concept can actually be deployed to kubernetes with little fanfare, so k8s is a potential
in our future as we grow

## Services

Services are target states of containers within a swarm cluster.

  * As an example, you can define a desired replica count of 4.  This means the cluster will
    attempt to startup 4 instances of the application.
    * Access to these applications is round robbin balanced by name.
      * "name" is the "load balancer", "name.1" is the first replica, "name.2 is the second", etc.

**To show the current services:**
```
docker service ls
```

**To examine information about the service such as its location within the cluster:**
```
docker service ps (name)
```

**To restart a container, you can force an update to the service:**
```
docker service update --force (name)
```

**To manually tear down a service:**
```
docker service rm (name)
```

> You can also remove the service from a stack's yaml and deploy it to remove it from the cluster.
> Removing a service will not remove the persistent data volumes attached to it.
> Removing a volume **WILL** remove a persistent data volume and data will be lost.

## Nodes

> We only have one node for the moment, but here are the basics.

  * Additional nodes can be added to grow
    * Adding nodes to a cluster is fairly straight forward as long as all the correct ports have been opened in the firewall.
    * As applications can exist on any node, we need a way to "attach" remote storage where it is needed.
      * Rexray can handle this by attaching up to 7 digital ocean volumes to a system as needed, but it was unstable at scale.
      * A private shared storage service would be idea such as NFS, but this is more expensive.
  * Applications can target nodes based on their size.
    (small apps go on "small tier" nodes, big apps target "big tier nodes")
