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
