resource "digitalocean_kubernetes_cluster" "haiku-prod-ams3" {
  name           = "haiku-prod-ams3"
  region         = "ams3"
  version        = "1.30.10-do.0"
  auto_upgrade   = true
  ha             = true

  maintenance_policy {
    day        = "sunday"
    start_time = "08:00"
  }

  node_pool {
    name         = "haiku-prod-ams3-general"
    size         = "s-4vcpu-8gb"
    node_count   = 3
    auto_scale   = false
  }
}
