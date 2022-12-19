module "enable_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.0"

  project_id  = var.project_id
  enable_apis = true
  disable_services_on_destroy = false
  
  activate_apis = [
    "memcache.googleapis.com",
  ]
}


module "memcache" {
  depends_on         = [module.enable_apis]
  source  = "terraform-google-modules/memorystore/google//modules/memcache"
  version = "4.4.1"
  region = var.region
  project = var.project_id
  name    = var.name
  # enable_apis = var.enable_apis
  authorized_network = "projects/${var.project_id}/global/networks/${var.vpc_network_name}"
  node_count = var.node_count
  cpu_count = var.cpu_count
  memory_size_mb = var.memory_size_mb
  zones = var.zones
  labels = merge(var.labels, var.default_labels)
  params = var.params
}