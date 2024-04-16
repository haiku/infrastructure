# OpenTofu

This contains the [OpenTofu](https://opentofu.org) code for our Kubernetes cluster at Digital Ocean.

## Usage

> There's currently no state file stored anywhere, given the simple infra for now we can just
> import "the one cluster"

  1. tofu init
  2. tofu import -var "do_token=SECRET_PAT" digitalocean_kubernetes_cluster.haiku-prod-ams3 (CLUSTER UUID)
  3. tofu plan -var "do_token=SECRET_PAT"

