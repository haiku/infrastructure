resource "digitalocean_droplet" "mail" {
  image   = "103136371"
  backups = true
  name    = "mx.ams3.haiku-os.org"
  region  = "ams3"
  size    = "s-1vcpu-1gb-amd"
  tags    = [
    "mail",
  ]
}
