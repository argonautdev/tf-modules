module "memcache" {
  source  = "terraform-google-modules/memorystore/google//modules/memcache"
  version = "4.4.1"
  region = var.region
  project = var.project_id
  name    = var.name
  authorized_network = "projects/${var.project_id}/global/networks/${var.vpc_network_name}"
  node_count = var.node_count
  cpu_count = var.cpu_count
  memory_size_mb = var.memory_size_mb
  zones = var.zones
  labels = merge(var.labels, var.default_labels)
  params = var.params
}