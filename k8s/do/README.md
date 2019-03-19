## Digital Ocean

These are used when deploying to Digital Ocean.
(and can be modified for other k8s environments)

## ingress-controller

This is the core ingress controller we use (traefik) modified
to properly exist within a Digital Ocean k8s environment.

## persistantstorage

By default the storage class at Digital Ocean deletes persistant
volumes when the services are deleted (kubectl delete -f XXX.yml)

Since I see us easily losing data with this design, i've modified
the Digital Ocean storage class to ensure persistant volumes... persist.
