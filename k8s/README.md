# Haiku Kubernetes manifests

I'm just playing around with what it would take to translate the
docker-compose manifests to Kubernetes.

> Warning:  These are just tests for reference and are not used
> at this time!

## References

  * Kubernetes persistant volume choices
    * https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes

## Deploying to a cluster

```kubectl apply -f service.yml```

## Tearing down from a cluster

```kubectl delete -f service.yml```
