# Haiku Traefik Ingress

This is the main ingress controller for Haiku's infrastructure running under Kubernetes

## What is an ingress controller?

An IngressController is a http/https reverse proxy which routes incoming requests to various
services available within the kubernetes cluster.

The IngressController's job is to expose pod routes via various Ingress specifications.

## Requirements

This was tested on Vultr, but should work for any managed k8s provider where load-balancers
are auto-created from the k8s, and storage classes are ReadWriteOnce

## How does this all work?

(internet) -> (Vultr Load Balancer) -> Kubernetes Nodes -> Ingress Controllers -> Ingress -> Service -> Pod

* There is one IngressController (Traefik) running per Kubernetes Node
* The Vultr Load Balancer is deployed via the IngressController's LoadBalancer entry

## What about SSL?

Traefik works with cert-mananger to prove proof-of-ownership of various URL's through LetsEncrypt.
ACME HTTP proof to be technical

### How are certs provisoned?

1. cert-manager picks up on ingresses with the following annotation:
    ```
    cert-manager.io/cluster-issuer: letsencrypt-production
    ```
    > It is recommended to not add the cert-issuer annotation until DNS has been switched over!
    > cert-manager could easily exhaust the maximum failed SSL cert requests per day if it loops indefinitely
    > asking for a DNS name which doesn't valdidate!
2. When an ingress is discovered with the above annotation, cert-manager attempts to provision a certificate for it through letsencrypt ACME HTTP validation.
3. cert-manager examines the tls.hosts of the ingress to determine which domains it needs a certificate for.
4. If a certificate is successfully obtained, it is stored within kubernetes in the secret name specified at tls.secretName.
5. Traefik detects a secret at tls.secretName in the ingress, and uses it for the ingress.
