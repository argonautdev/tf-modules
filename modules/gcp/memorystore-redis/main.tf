module "memorystore" {
  source  = "terraform-google-modules/memorystore/google"
  version = "5.1.0"
  region = var.region
  project = var.project_id
  name    = var.name
  authorized_network = var.vpc_network_name
  tier = var.tier
  memory_size_gb = var.memory_size_gb
  replica_count = var.replica_count
  read_replicas_mode = var.read_replicas_mode
  location_id = var.location_id
  alternative_location_id = var.alternative_location_id
  redis_version = var.redis_version
  redis_configs = var.redis_configs
  connect_mode = var.connect_mode
  labels = merge(var.labels, var.default_labels)
  auth_enabled = var.auth_enabled
  maintenance_policy = var.maintenance_policy
  transit_encryption_mode = var.transit_encryption_mode
}

data "google_redis_instance" "export_redis_instance_info" {
  depends_on = [module.memorystore]
  name = var.name
  region = var.region
  project = var.project_id
}