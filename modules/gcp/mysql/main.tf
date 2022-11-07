##To Work with cloudSQL module, The following APIs should be enabled.
module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.3"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "sqladmin.googleapis.com", ##API is required if we would want to connect via CloudSQL auth proxy.
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

resource "null_resource" "previous" {
  depends_on = [module.enabled_google_apis]
  provisioner "local-exec" {
    command = "echo \"waiting for 60 seconds before starting resources creation\""
  }
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [module.enabled_google_apis, null_resource.previous]
  create_duration = "60s"
}

resource "null_resource" "after" {
  depends_on = [module.enabled_google_apis, time_sleep.wait_60_seconds]
  provisioner "local-exec" {
    command = "echo \"wait is over!!! starting resources creation\""
  }
}

// Data Block for getting VPC self link
data "google_compute_network" "my-network" {
    depends_on = [null_resource.after]
    name = var.vpc_network_name
    project = var.project_id
}

locals {
  ip_configuration = {
      ipv4_enabled = var.db_connectivity_type == "private" ? false : true
      allocated_ip_range = var.db_connectivity_type == "private" ? var.private_service_access_name : null
      authorized_networks = var.authorized_networks
      //The VPC network from which the Cloud SQL instance is accessible for private IP
      private_network = var.db_connectivity_type == "private" ? data.google_compute_network.my-network.self_link : null
      require_ssl = var.require_ssl
  }
  read_replicas = length(var.read_replicas) > 0 ? flatten([
    for each_replica in var.read_replicas: {
        name = each_replica.name
        tier = each_replica.tier
        zone = each_replica.zone
        disk_type = each_replica.disk_type
        disk_autoresize = each_replica.disk_autoresize
        database_flags = each_replica.database_flags
        disk_autoresize_limit = each_replica.disk_autoresize_limit
        disk_size = each_replica.disk_size
        user_labels = each_replica.user_labels
        encryption_key_name = each_replica.encryption_key_name
        ip_configuration =  local.ip_configuration
  }]): []
}

module "mysql" {
    depends_on = [null_resource.after]
    source = "GoogleCloudPlatform/sql-db/google//modules/mysql"
    version = "11.0.0"
    project_id = var.project_id
    region = var.region
    zone = var.zone
    name = var.name
    tier = var.db_compute_instance_size
    activation_policy = var.activation_policy
    availability_type = var.availability_type
    ip_configuration = local.ip_configuration
    backup_configuration = {
        binary_log_enabled             = var.binary_log_enabled
        enabled                        = var.enabled
        start_time                     = var.start_time
        location                       = var.location
        transaction_log_retention_days = var.transaction_log_retention_days
        retained_backups               = var.retained_backups
        retention_unit                 = var.retention_unit
    }
    database_version = var.database_version
    disk_autoresize = var.disk_autoresize
    disk_autoresize_limit = var.disk_autoresize_limit
    disk_size = var.disk_size
    db_name = var.db_name
    deletion_protection = var.deletion_protection
    additional_databases = var.additional_databases
    user_name = var.user_name
    user_password = var.user_password
    additional_users = var.additional_users
    maintenance_window_day = var.maintenance_window_day
    maintenance_window_hour = var.maintenance_window_hour
    user_labels = merge(var.user_labels, var.default_labels)
    pricing_plan = var.pricing_plan
    read_replicas = local.read_replicas
}