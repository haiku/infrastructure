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

### Applying a deployment on a cluster

```kubectl apply -f service.yml```

### Deleting a deploymeny from a cluster

> Warning: Deleting a deployment will disconnect the persistant storage
> from the pods, and i've yet to determine how to reattach. Be prepared
> to restore from backups. (run the snapshot job before doing this!)

```kubectl delete -f service.yml```

## Rolling out infrastructure

### Deploy cert-mananger

Cert-mananger will manange automatically renewing TLS certificates in our cluster
and pass them to Traefik.

> Using Traefik's native Lets Encrypt support is a *lot* easier and more reliable
> however it only supports 'single Traefik instance' deployments now.
> The 'Traefik Enterprise' edition supports multiple instances and Lets Encrypt, but
> it's too expensive for our use.

```kubectl apply -f deployments/ingress/cert-mananger.yml```

### Deploy cert-mananger-acme

This configured cert-mananger to leverage Lets Encrypt for TLS certificate generation.
Validation occurs via http01 ACME authentication.

```kubectl apply -f deployments/ingress/cert-mananger-acme.yml```

These solve https://github.com/jetstack/cert-manager/issues/2640 ?

```kubectl delete mutatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook```
```kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io/cert-manager-webhook```

### Deploy Traefik

Traefik is a reverse proxy which acts as an Ingress controller.

```kubectl apply -f deployments/ingress/traefik.yml```

### Deploy "everything else"

```kubectl apply -f deployments/XXX.yml```
