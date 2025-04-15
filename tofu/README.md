# OpenTofu

This contains the [OpenTofu](https://opentofu.org) code for our Kubernetes cluster at Digital Ocean.

## Usage

> There's currently no state file stored anywhere (DO s3 costs money at any size).
> For now, we can just import the existing infrastructure.

  1. export TF_VAR_do_token=dop_personal_access_token...
  2. tofu init
  3. tofu import digitalocean_kubernetes_cluster.haiku-prod-ams3 e1331baa-1a37-4779-a2f4-22e138a3613e
  4. tofu import digitalocean_droplet.mail 288993384
  5. tofu plan
