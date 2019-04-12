# Haiku Kubernetes manifests

I'm just playing around with what it would take to translate the
docker-compose manifests to Kubernetes.

> Warning:  These are just tests for reference and are not used
> at this time!

## Directories

  * deployments - various infrastructure that's deployed and used to serve requests
  * jobs - run-once jobs to accomplish various tasks
  * providers - various support infrastructure needed for various providers.

## References

  * Kubernetes persistant volume choices
    * https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes

## Applying a deployment on a cluster

```kubectl apply -f service.yml```

## Deleting a deploymeny from a cluster

> Warning: Deleting a deployment will disconnect the persistant storage
> from the pods, and i've yet to determine how to reattach. Be prepared
> to restore from backups. (run the snapshot job before doing this!)

```kubectl delete -f service.yml```
