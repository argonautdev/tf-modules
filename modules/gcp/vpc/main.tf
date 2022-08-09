module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.3"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "compute.googleapis.com" ##Compute Storage API
  ]
}


module "vpc" {
  source           = "terraform-google-modules/network/google"
  version          = "~> 4.0"
  project_id       = var.project_id
  network_name     = var.network_name
  description      = var.description
  subnets          = var.subnets
  # secondary_ranges = var.secondary_ranges ##Removing this as this is not required at the moment.
}

################################
# Nat and Routetable creation  #
################################
module "cloud_router" {
  depends_on  = [module.vpc]
  source      = "terraform-google-modules/cloud-router/google"
  version     = "2.0.0"
  name        = var.router_name
  description = var.router_description
  project     = var.project_id
  region      = var.region
  network     = var.network_name
  nats        = var.nats
}


